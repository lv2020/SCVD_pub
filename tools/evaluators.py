import json
#读取配置实现统一的测试

class Detector(object):
    def __init__(self, tool):
        super(Detector, self).__init__()
        self.config = json.load(f'./configs/{tool}.json')
    
    def detect(self, file_path, bug_type):
        '''
        detect the bug in the file
        Args:
            file_path: path of the file
            bug_type: type of the bug
        Return:
            True if the bug is detected
        '''
        pass