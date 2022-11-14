# A New Smart Contract Vulnerability Dataset
## Installation
We provide a docker [container](https://drive.google.com/file/d/18ByjMjeIHhFr-x90zicVOhlmXIjm56Pr/view?usp=sharing). It is easier to run it. You can also choose to manually install. Commands are listed. 
```
conda create -n SCVD python=3.7.6
conda activate SCVD
pip3 install -r requirements.txt
```
You also need to install npm.

## File Structure
```
.
├── crawler
│   ├── crawler.py          //file for downloading commits
│   ├── filter.py           //file for filtering commits 
│   ├── helpers.py          //file for help functions
│   ├── processing.py       //file for processing commits
│   └── settings.py         //file for storing important settings
├── log                     //folder for storing logs
├── tmp                     //folder for storing projects
├── tmp_data                //folder for storing downloaded commits
├── tmp_results             //folder for storing results
├── bug_data                //folder for storing vulnerabilites
├── flatten.py              //file for flattening files
├── main.py
├── README.md
└── requirements.txt
```
## Usage
Before running the project, you need to set GITHUB_TOKEN and NODE_LIB_PATH under crawler/settings.py. For GITHUB_TOKEN, please refer to [GitHub](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) to generate the key. For NODE_LIB_PATH, it is the path of node library. 
## Download the commits
```
python3 crawler/crawler.py 2022-09 2022-10
```
### Filter useless files
```
python3 crawler/filter.py reentrancy
```
### Process 
```
python3 crawler/processing.py reentrancy
```
The processed details and code are stored at bugdata/reentrancy_details and bug_data/reentrancy_files, respectively. Here, reentrancy can be replaced with any keywords you want to search.  
### Test
For testing, please refer to [smartbugs](https://github.com/smartbugs/smartbugs)

### Limtation
Due to time constraints, there is considerable room for improvement in this project. First, during the filtering, we only use exact matches to decide whether a commit is related to vulnerability. This can be improved in two aspects: (1) use the word stem instead of the word. For example, some people may prefer 're-entrancy' instead of 'reentrancy'. Therefore, we will miss some of them if only use 'reentrancy'. (2) use a word pool instead of a single word. The same vulnerability may have different representations in different tools. For example, some tools are using 'reentrancy' while another may use 'DAO' to represent the same vulnerability. To improve this, we may need to build a keyword pool first to include all possible keywords. Despite sounding pricey, it is disposable and has an endless lifespan. 

Second, a significant portion of the files is invalid due to compilation errors and import errors. They may be able to come back into play with automated environment builds and automated code repair. Besides, false positives still happen occasionally, such as when another file is fixed instead of the smart contract. Furthermore, the presence of the keyword and fix on the same line does not imply that the commit contains a fix for the associated vulnerability. These compel us to suggest a filtering method that is more effective.