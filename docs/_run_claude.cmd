@echo off
cd /d E:\scripts-python\OrionHealth\docs
type _prompt.txt | claude -p --dangerously-skip-permissions --print > C:\Users\belal\clawd\_claude_output.txt 2> C:\Users\belal\clawd\_claude_error.txt
echo EXIT_CODE=%ERRORLEVEL% >> C:\Users\belal\clawd\_claude_output.txt
