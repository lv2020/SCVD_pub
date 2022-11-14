import os
import json
import urllib.parse
import subprocess
import sys
from helpers import *
from settings import *

class Processor(object):
    def __init__(self, filename, keyword):
        super(Processor, self).__init__()
        commit_id = filename.split('/')[-1].split('.')[0]
        self.log = open(f'./log/{keyword}/{commit_id}.log', 'w')
        self.tmp_path = 'tmp'
        self.lib_path = NODE_LIB_PATH

    def run_write_log(self, command):
        ret = subprocess.run(command,shell=True,stdout=subprocess.PIPE, stderr=subprocess.STDOUT, encoding="utf-8")
        self.write_log(ret.stdout)
    
    def write_log(self, message):
        self.log.write(message+'\n')

    def download_fixed_file(self, raw_url):
        self.run_write_log(f'wget {raw_url}')
        filename = raw_url.split('/')[-1].split('?')[0]
        #check the download is successful
        if os.path.exists(filename):
            code = open(filename).read()
            self.run_write_log(f'rm -f {filename}')
            return code
        else:
            return ''

    def download_files(self, record):
        #download the file before and after the commit
        parent_commit_id = record['parents'][0]['html_url'].split('/')[-1]
        commit_id = record['sha']

        for file in record['files']:
            if file['raw_url'].endswith('.sol'):
                project_url = file['raw_url'].split('/raw/')[0]
                filename = urllib.parse.unquote(file['raw_url'].split('/')[-1])
                break
        self.write_log(f'Details: {parent_commit_id} {commit_id} {project_url} {filename}')
        bug_file, flattened_bug_file, fixed_file, flattened_fixed_file = self.download_project(self.tmp_path, project_url, parent_commit_id, commit_id, filename)

        return bug_file, flattened_bug_file, fixed_file, flattened_fixed_file, parent_commit_id, commit_id

    def build_sample(self, record):
        data_sample = {}
        for i in record['files']:
            if i['filename'].endswith('.sol'):
                data_sample['filename'] = i['filename']
                data_sample['patch'] = i['patch']
        data_sample['project_link'] = record['html_url']

        data_sample['bug_version'] = {}
        data_sample['fixed_version'] = {}

        bug_file, flattened_bug_file, fixed_file, flattened_fixed_file, parent_commit_id, commit_id = self.download_files(record)
        data_sample['bug_version']['raw_code'] = bug_file
        data_sample['bug_version']['flattened_code'] = flattened_bug_file
        data_sample['bug_version']['commit_id'] = parent_commit_id
        data_sample['fixed_version']['raw_code'] = fixed_file
        data_sample['fixed_version']['flattened_code'] = flattened_fixed_file
        data_sample['fixed_version']['commit_id'] = commit_id
        data_sample['solc_version'] = get_curr_solc_version()
        data_sample['packages'] = get_curr_packages()
        return data_sample

    def store_sample(self, keyword, data_sample):
        with open(f'./bug_data/{keyword}_details/{data_sample["bug_version"]["commit_id"]}.json', 'w') as f:
            f.write(json.dumps(data_sample))
        if data_sample['bug_version']['flattened_code'] != '':
            with open(f'./bug_data/{keyword}_files/{data_sample["bug_version"]["commit_id"]}.sol', 'w') as f:
                f.write(data_sample['bug_version']['flattened_code'])

    def extract_project_git_url(self, project_link):
        tmp = project_link.split('/commit')[0].split('.com/')[1]
        project_git_url = f'https://github.com/{tmp}.git'
        return project_git_url

    def download_project(self, tmp_path, project_git_url, bug_commit_id, fixed_commit_id, filename):
        '''
        download the project and switch it to specific version
        Args:
            project_url: url of the project
            commit_id: commit id
        '''
        os.chdir(f'{self.tmp_path}')
        project_name = project_git_url.split('/')[-2]+ '_'+project_git_url.split('/')[-1].split('.')[0]
        if not os.path.exists(project_name):
            m = os.popen(f'git clone {project_git_url} {project_name}').read()
        #check the git clone is successful
        if not os.path.exists(project_name):
            self.write_log('git clone failed')
            return '', '', '', ''
        os.chdir(f'./{project_name}')
        bug_file, flattened_bug_file = self.processing_file(bug_commit_id, filename)
        if flattened_bug_file == '':
            return '', '', '', ''
        fixed_file, flattened_fixed_file = self.processing_file(fixed_commit_id, filename)
        return bug_file, flattened_bug_file, fixed_file, flattened_fixed_file
    
    def processing_file(self, commit_id, filename):
        os.popen(f'git checkout {commit_id}').read()
        if os.popen('git rev-parse HEAD ').read().strip() != commit_id:
            self.write_log('git checkout failed')
            return '', ''
        raw_file = open(filename).read()
        flattened_file = self.generate_flatten_file(filename)
        return raw_file, flattened_file

    def generate_flatten_file(self, filename):
        '''
        generate the flatten file
        Args:
            filename: name of the file
        '''
        flag, code = self.flatten_file(filename)
        '''
        if not flag:
            #if failed due to missing library, install the library
            if code == 'Failed to generate flatten file':
                install_library(filename, self.lib_path, self.log)
                flag, code = self.flatten_file(filename)
        '''
        if not flag:
            if os.path.exists('package.json'):
                m = os.popen(f'npm install --prefix {self.lib_path} package.json').read()
                flag, code = self.flatten_file(filename)

        if flag:
            return code
        else:
            return ''

    def flatten_file(self, filename):
        '''
        flatten the file
        Args:
            filename: name of the file
            lib_path: path to solc library
        Return:
            flag: success
        '''
        self.run_write_log(f'python3 ../../flatten.py --path {filename} --output ./flatten.sol  --include {self.lib_path}/node_modules')
        return self.check_flatten_file('./flatten.sol')

    def check_flatten_file(self, filename):
        '''
        check the flatten file
        Args:
            filename: name of the file
        Return:
            flag: failed or not
            code: return code
        '''
        if os.path.exists(filename):
            build_environment(filename)
            ret = subprocess.run(f'solc {filename}',shell=True,stdout=subprocess.PIPE, stderr=subprocess.STDOUT, encoding="utf-8")
            if 'error' in ret.stdout.lower():
                self.write_log(ret.stdout)
                return False, 'Failed to pass the solc'
            else:
                return True, open(f'./{filename}').read()
        else:
            self.write_log('generate flatten file failed')
            return False, 'Failed to generate flatten file'

    def clean_environment(self, project_name):
        '''
        clean the environment
        '''
        os.popen(f'rm -rf {project_name}').read()



def running(keyword):
    filenames = json.load(open(f'./tmp_results/filtered_results_{keyword}.json'))
    if not os.path.exists(f'./bug_data/{keyword}_details'):
        os.mkdir(f'./bug_data/{keyword}_details')
    if not os.path.exists(f'./bug_data/{keyword}_files'):
        os.mkdir(f'./bug_data/{keyword}_files')
    if not os.path.exists(f'./log/{keyword}'):
        os.mkdir(f'./log/{keyword}')
    for filename in filenames:
        curr_path = os.getcwd()
        p = Processor(filename, keyword)
        record = json.load(open(filename))
        if os.path.exists(f"./bug_data/{keyword}_files/{record['parents'][0]['html_url'].split('/')[-1]}.sol"):
            #continue
            pass
        data_sample = p.build_sample(record)
        os.chdir(curr_path)
        p.store_sample(keyword, data_sample)

if __name__ == '__main__':
    running(sys.argv[1])