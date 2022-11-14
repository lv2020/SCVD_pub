#filter and rank the results
import json
from tqdm import tqdm
from glob import glob
import multiprocessing
import os
import time
import sys
from settings import * 

class Filter(object):
    def __init__(self, keyword):
        super(Filter, self).__init__()
        self.keyword = keyword
        self.output_keyword = '_'.join(keyword.split(' '))
        self.build_env()

    def build_env(self):
        if not os.path.exists(f'./tmp_results/{self.output_keyword}'):
            os.mkdir(f'./tmp_results/{self.output_keyword}')

    def primary_filter(self, files):
        tmp_results = {}
        for f in tqdm(files):
            record = json.load(open(f))
            for commit in record:
                #the commit message should contain the keyword
                if self.keyword in record[commit].lower():
                    tmp_results[commit] = record[commit]
        return tmp_results


    def primary_ranker(self, data_path):
        '''
        rank the results based on the primary criteria
        Args:
            keyword: keyword for searching
            data_path: path of the data
        '''
        tmp_results = {}
        records = glob(f'{data_path}/*.json')
        with multiprocessing.Pool(processes = 30) as pool:
            jobs = []
            for i in range(30):
                jobs.append(pool.apply_async(self.primary_filter, ( records[i::30], )))
            
            for job in jobs:
                tmp_results.update(job.get())
        #store the primary results for next step
        with open(f'./tmp_results/{self.output_keyword}_tmp_results.json', 'w') as f:
            f.write(json.dumps(tmp_results))
        #return tmp_results
    
    def secondary_ranker(self):
        records = json.load(open(f'./tmp_results/{self.output_keyword}_tmp_results.json'))
        #download the detailed data from GitHub
        count = 0
        for i, commit in enumerate(records):
            if self.message_check(self.keyword, records[commit]) and not os.path.exists(f'./tmp_results/{self.output_keyword}/{commit}.json'):
                details = os.popen(f'curl "Accept: application/vnd.github+json" -H "Authorization: Bearer {GITHUB_TOKEN}" "{commit}"').read()
                commit_id = commit.split('/')[-1]
                with open(f'./tmp_results/{self.output_keyword}/{commit_id}.json', 'w') as f:
                    f.write(details)
                count += 1
            if count % 5000 == 0 and count > 0:
                #sleep one hour to avoid the rate limit
                time.sleep(50 * 60)
        res = self.language_check()
        return res

    def language_check(self):
        '''
        check the language of the commit
        Args:
            commit_id: id of the commit
        Return:
            True if the language is solidity
        '''
        records = glob(f'./tmp_results/{self.output_keyword}/*.json')
        tmp_results = []
        for record in records:
            parsed_record = json.load(open(record))
            if 'files' not in parsed_record:
                continue
            count_sol = 0
            for file in parsed_record['files']:
                #the file should end with .sol and come from previous file
                if file['filename'].endswith('.sol') and file['status']=='modified':
                    count_sol += 1
            #ignore the commit if the number of changed solidity files is more than 1 first
            if count_sol == 1:
                tmp_results.append(record)
        with open(f'./tmp_results/filtered_results_{self.output_keyword}.json', 'w') as f:
            f.write(json.dumps(tmp_results))

    def ast_difference(self, commit_id):
        '''
        check the difference of the AST
        Args:
            commit_id: id of the commit
        Return:
            changes: the number of changes before and after the commit
        '''
        pass
    
    def message_check(self, keyword, message):
        '''
        Fix and keyword should appear at the same line
        Args:
            keyword: keyword for searching
            message: commit message
        Return:
            True if the keyword and fix appear at the same line
        '''
        for line in message.lower().split('\n'):
            if 'fix' in line and keyword in line:
                return True
            else:
                return False
    
    def running(self, data_path):
        #must contrain the keyword
        self.primary_ranker(data_path)
        #the language should be solidity
        self.secondary_ranker()

if __name__ == '__main__':
    keyword = sys.argv[1].lower()
    data_path = './tmp_data'
    filter = Filter(keyword)
    filter.running(data_path)
    #filter.primary_ranker(data_path)
    #filter.secondary_ranker()