@echo off
cd /d E:\scripts-python\orionhealth
gh pr view 459 --repo iberi22/OrionHealth --json number,state,mergeable,title --jq "{number, state, mergeable}"
gh pr view 460 --repo iberi22/OrionHealth --json number,state,mergeable --jq "{number, state, mergeable}"
gh pr view 461 --repo iberi22/OrionHealth --json number,state,mergeable --jq "{number, state, mergeable}"
gh pr view 462 --repo iberi22/OrionHealth --json number,state,mergeable --jq "{number, state, mergeable}"
gh pr view 463 --repo iberi22/OrionHealth --json number,state,mergeable --jq "{number, state, mergeable}"
gh pr view 464 --repo iberi22/OrionHealth --json number,state,mergeable --jq "{number, state, mergeable}"
