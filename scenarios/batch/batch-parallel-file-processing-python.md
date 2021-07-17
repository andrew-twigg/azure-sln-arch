# Run a parallel workload with Azure Batch using the Python API

Ref. https://docs.microsoft.com/en-us/azure/batch/tutorial-parallel-python

## Prereqs

- [An Azure Batch Account with linked storage account](batch-quickstart.md)

## Get Creds 

Get batch account endpoint and key, and storage key...

```sh
bae=$(az batch account show -g $rg -n $ba --query 'accountEndpoint' -o tsv)
bak=$(az batch account keys list -g $rg -n $ba --query "primary" -o tsv)
sak=$(az storage account keys list -g $rg -n $sa --query "[?keyName=='key1'].value" -o tsv)
```

## Download sample

Download the sample and install the requirements into an environment. Using conda on Mac M1.

```sh
git clone https://github.com/Azure-Samples/batch-python-ffmpeg-tutorial.git
cd batch-python-ffmpeg-tutorial/src/

conda create --name env$id
conda activate env$id

pip install -r requirements.txt
```

## Update the config file

```sh
sed -i '' -e "s,_BATCH_ACCOUNT_NAME.*,_BATCH_ACCOUNT_NAME = '$ba',g" config.py
sed -i '' -e "s,_BATCH_ACCOUNT_KEY.*,_BATCH_ACCOUNT_KEY = '$bak',g" config.py
sed -i '' -e "s,_BATCH_ACCOUNT_URL.*,_BATCH_ACCOUNT_URL = 'https://$bae',g" config.py
sed -i '' -e "s,_STORAGE_ACCOUNT_NAME.*,_STORAGE_ACCOUNT_NAME = '$sa',g" config.py
sed -i '' -e "s,_STORAGE_ACCOUNT_KEY.*,_STORAGE_ACCOUNT_KEY = '$sak',g" config.py
```

Check the config file contains all the values...

```sh
vim config.py
```

## Run the job

```sh
(env29271) andrew@Andrews-MacBook-Air src % python3 batch_python_tutorial_ffmpeg.py 
Sample start: 2021-07-17 10:56:57

Container [input] created.
Container [output] created.
Uploading file /Users/andrew/azure-sln-arch/scenarios/batch/batch-python-ffmpeg-tutorial/src/InputFiles/LowPriVMs-1.mp4 to container [input]...
Uploading file /Users/andrew/azure-sln-arch/scenarios/batch/batch-python-ffmpeg-tutorial/src/InputFiles/LowPriVMs-2.mp4 to container [input]...
Uploading file /Users/andrew/azure-sln-arch/scenarios/batch/batch-python-ffmpeg-tutorial/src/InputFiles/LowPriVMs-3.mp4 to container [input]...
Uploading file /Users/andrew/azure-sln-arch/scenarios/batch/batch-python-ffmpeg-tutorial/src/InputFiles/LowPriVMs-4.mp4 to container [input]...
Uploading file /Users/andrew/azure-sln-arch/scenarios/batch/batch-python-ffmpeg-tutorial/src/InputFiles/LowPriVMs-5.mp4 to container [input]...
Creating pool [LinuxFfmpegPool]...
Creating job [LinuxFfmpegJob]...
Adding 5 tasks to job [LinuxFfmpegJob]...
Monitoring all tasks for 'Completed' state, timeout in 0:30:00.........................................................................................................................................................................................................................................................................................
  Success! All tasks reached the 'Completed' state within the specified timeout period.
Deleting container [input]...

Sample end: 2021-07-17 11:02:41
Elapsed time: 0:05:44

Delete job? [Y/n] Y
Delete pool? [Y/n] Y

Press ENTER to exit...
```

## Clean up

```sh
az group delete -g $rg --no-wait -y

conda deactivate
conda env remove --name env$id
```
