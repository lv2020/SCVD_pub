This is for adding configurations for new tools.

To add a new tool, you need to add a configuration file under configs folder. The structure would be:
```
{
    "tool_name": "slither" //The name for tool
    "detect_command": "slither {} --detect {}", // the running command for tool
    "bug_conversion": { //the conversion rule for bugs
        "reentrancy": "reentrancy-eth", 
    }
}
```