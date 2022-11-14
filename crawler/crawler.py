#download data from github
import json
import os
import multiprocessing
import datetime
from datetime import timedelta, datetime
import sys

class Crawler(object):
    def __init__(self):
        super(Crawler, self).__init__
        pass 

    def set_commit_query(self, keywords, rank, time_range):
        '''
        set the query of commit based on given requirements:
        Args:
            keywords: keywords for searching
            rank: rank of the result
            time_range: time range of the result
        Return:
            query: query string
        '''
        serarh_keywords = '+'.join(keywords)
        query = f'curl   -H "Accept: application/vnd.github+json"  "https://api.github.com/search/commits?q={serarh_keywords}&per_page=100"'

        return query

    def build_folder(self):
        #create  folder for logging and storing data
        if not os.path.exists('./log'):
            os.mkdir('./log')
        if not os.path.exists('./tmp_data'):
            os.mkdir('./tmp_data')

    def filter(self, data, bug_keywords):
        '''
        filter useless data
        Args:
            data: data to be filtered
            bug_keywords: keywords for filtering
        Return:
            commit_message: filtered dict of commit and message
        '''
        commit_message = {}
        data = [json.loads(i) for i in data if 'message' in i]
        data = [i for i in data if 'commits' in i['payload']]
        #data = [i for i in data if 'fix' in i['payload']['commits'][0]['message'].lower()]
        #check for keywords
        for commit in data:
            for message in commit['payload']['commits']:
                #if 'fix' in message['message'].lower() and len([j for j in bug_keywords if j in message['message'].lower()]) > 0:
                #if 'fix' in message['message'].lower():
                if self.check_keywords(message['message']):
                    commit_message[message['url']] = message['message']
        return commit_message
    
    def check_keywords(self, message):
        '''
        check if the message contains keywords
        '''
        #keywords = ['reentrancy', 'Oracle Manipulation', 'Frontrunning', 'Timestamp Dependence', 'Insecure Arithmetic', 'Denial of Service', 'Griefing', 'Force Feeding']
        keywords = ['fix']
        keywords = [i.lower() for i in keywords]
        for i in keywords:
            if i in message.lower():
                return True
        return False
    
    def clean_files(self, date):
        '''
        clean useless files
        '''
        os.popen(f'rm -f {date}*').read()
        os.popen(f'rm -f {date}*').read()
        os.popen(f'rm -f wget*').read()

    def download_data_per_hour(self, archive_time):
        '''
        download data from GH archive API, https://www.gharchive.org/
        Args:
            archive_time: time of the data 
            to be downloaded
        Return:
            data: downloaded data
        '''
        self.clean_files(archive_time)
        os.popen(f'wget https://data.gharchive.org/{archive_time}.json.gz').read()
        os.popen(f'gzip -d {archive_time}.json.gz').read()
        try:
            with open(f'{archive_time}.json', 'r') as f:
                data = f.readlines()
                data = self.filter(data, self.bug_keywords)
        except:
            with open(f'./log/failed_log.txt', 'a+') as f:
                f.write(f'{archive_time}.json\n')
                data = {}
        os.popen(f'rm -f {archive_time}.json.gz').read()
        os.popen(f'rm -f {archive_time}.json').read()
        return data

    def download_data_per_day(self, archive_time):
        '''
        gather data from hours of a day
        '''
        data = {}
        for i in range(24):
            if os.path.exists(f'./tmp_data/{archive_time}.json'):
                return '123'
            data.update(self.download_data_per_hour(f'{archive_time}-{i}'))
        with open(f'./tmp_data/{archive_time}.json', 'w') as f:
            f.write(json.dumps(data))
        #return data

    def running(self, start_date, end_date, bug_keywords):
        '''
        Run the crawler
        Args:
            start_date: start date of the data to be downloaded, e.g. 2022-1-1
            end_date: end date of the data to be downloaded
            bug_keywords: keywords for filtering
        Return:
            data: downloaded data
        '''
        start_date = datetime.strptime(start_date, '%Y-%m-%d')
        end_date = datetime.strptime(end_date, '%Y-%m-%d')
        self.bug_keywords = bug_keywords
        self.build_folder()
        
        with multiprocessing.Pool(processes = 10) as pool:
            jobs = []
            while start_date < end_date:
                jobs.append(pool.apply_async(self.download_data_per_day, (start_date.strftime('%Y-%m-%d'),)))
                start_date += timedelta(days=1)
            for job in jobs:
                job.get()
        pool.close()
        pool.join()
    
if __name__ == '__main__':
    crawler = Crawler()
    crawler.running(sys.argv[1], sys.argv[2], ['fix'])