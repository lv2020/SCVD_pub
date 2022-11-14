import os
import json
from yaml import KeyToken
from tqdm import tqdm

def build_environment(file_path):
    '''
    build the solc environment for file
    Args:
        file_path: path of the file
    '''
    solc_version = detect_solc_version(file_path)
    install_solc(solc_version)
    switch_solc(solc_version)

def switch_solc(version):
    os.popen(f'solc-select use {version}').read()

def install_solc(version):
    os.popen(f'solc-select install {version}').read()

def detect_solc_version(file_path):
    text = open(file_path).readlines()
    text = [i for i in text if i.startswith('pragma solidity')]
    version = text[0].split(' ')[-1][:-1].replace('^', '')
    version = ''.join([i for i in version if i in '0123456789.'])
    return version

def get_curr_solc_version():
    #read and return the current solc version
    version = os.popen('solc --version').read().strip()
    version = version.strip().split('Version:')[1].split('+')[0].strip()
    return version

def get_curr_packages():
    #if there exists packages.json, read and return it
    if os.path.exists('package.json'):
        return json.load(open('package.json'))
    else:
        return ''


def extract_missing_library(filename):
    '''
    extract the missing library
    Args:
        filename: name of the file
    Return:
        missing_library: list of missing library
    '''
    missing_libraries = []
    text = open(filename).readlines()
    for line in text:
        if line.startswith('import') and '"@' in line:
            tmp = line.split('"@')[1].strip()
            missing_libraries.append('@' + '/'.join(tmp.split('/')[:2]))
    return list(set(missing_libraries))

def install_library(filename, libpath, log):
    '''
    install the missing library
    Args:
        filename: name of the file
    Return:
        flag: success or failed
    '''
    missing_libraries = extract_missing_library(filename)
    for missing_library in missing_libraries:
        if not os.path.exists(f'{libpath}/{missing_library}') and not os.path.exists(f'{libpath}/{missing_library}'.replace('@', '')):
            m = os.popen(f'npm install {missing_library}').read()


    
def test_install_library():
    '''
    test the function of installing library
    '''
    #build the environment
    m = os.popen(f'npm uninstall @chainlink/contracts').read()

    missing_library = extract_missing_library('./test/test_extract_missing_library.sol')
    assert missing_library[0] == '@'
    #recover the environment
    m = os.popen(f'npm install @chainlink/contracts').read()


def get_compilation_pass(path):
    res = glob(path)
    compilation_pass = []
    for i in res:
        if 'error' not in open(i).read().lower():
            compilation_pass.append(i)
    return compilation_pass

def check_detect(keyword, date, compilation_pass):
    detect = []
    passed_files = [i.replace('log', 'json') for i in compilation_pass]
    for f in passed_files:
        record = json.load(open(f))
        for check in record['analysis']:
            if 'check' not in check:
                if keyword in check['name'].lower():
                    detect.append(f.split('/')[-2])
                    break
            else:
                if keyword in check['check'] and len(check['elements']) > 0:
                    detect.append(f.split('/')[-2])
                    break
    return detect

    

def compare_tools(keyword, date):
    tools = os.listdir()
    tools = [i for i in tools if i != 'logs']

    compilation_pass = {}
    for tool in tools:
        compilation_pass[tool] = get_compilation_pass(f'./{tool}/{date}/*/result.log')
    
    detected = {}
    for tool in compilation_pass:
        detected[tool] = check_detect(keyword, date, compilation_pass[tool])
    
    return detected, compilation_pass

def print_results(detected, compilation_pass):
    for tool in detected:
        print(f'{tool}: {len(detected[tool])} / {len(compilation_pass[tool])}')


from tqdm import tqdm
def count_language(output_keyword):
    records = glob(f'./tmp_results/{output_keyword}/*.json')
    tmp_results = []
    count_sol = 0
    for record in tqdm(records):
        parsed_record = json.load(open(record))
        if 'files' not in parsed_record:
            continue
        for file in parsed_record['files']:
            #the file should end with .sol and come from previous file
            if file['filename'].endswith('.sol') and file['status']=='modified':
                count_sol += 1
                break
    return count_sol


def run_tools(keyword, files, tool):
    '''
    run the tools
    Args:
        keyword: keyword to search
        files: list of files to run
        tool: name of the tool
    '''
    for i in tqdm(files):
        details_name = i.replace('.sol', '.json')
        details = json.load(open(f'../{keyword}_details/{details_name}'))
        solc_version = details['solc_version']
        switch_solc(solc_version)
        if tool == 'slither':
            m = os.popen(f'slither {i} --json {i.replace(".sol", ".json.slither")}').read()
        else:
            pass

def slither_check(keyword, files):
    '''
    check the results of slither
    Args:
        keyword: keyword to search
        files: list of files to run
    Return:
        detected: the number of detected files
    '''
    detect = 0
    for i in files:
        record = json.load(open(i))
        if record['success']:
            for check in record['results']['detectors']:
                if keyword in check['check']:
                    detect += 1
                    break
    return detect