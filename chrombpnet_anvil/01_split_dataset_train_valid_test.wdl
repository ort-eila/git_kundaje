version 1.0

# chrombpnet prep splits -c ~/chrombpnet_tutorial/data/downloads/hg38.chrom.subset.sizes -tcr chr1 chr3 chr6 -vcr chr8 chr20 -op ~/chrombpnet_tutorial/data/splits/fold_0

workflow wf_split_dataset_train_valid_test {
  input {
    String yourOutputPrefix
    File   yourChromSizes
    String yourTestChroms
    String yourValidationChroms
  }
  

  call run_split_train_valid_test {
    input: 
      outputPrefix = yourOutputPrefix,
      chromSizes = yourChromSizes,
      testChroms = yourTestChroms,
      validationChroms = yourValidationChroms
  }
  
  output {
    File workflow_stdout_output = run_split_train_valid_test.response
    File workflow_ls_output = run_split_train_valid_test.ls_output
    File workflow_splits = run_split_train_valid_test.splits
  }
}

#################END OF WORKFLOW

task run_split_train_valid_test {
  input {
    String  outputPrefix
    File    chromSizes
    String	testChroms
    String	validationChroms
  }
  
  command {
    # cd /; mkdir chrombpnet
    # cd /chrombpnet
    # git clone https://github.com/kundajelab/chrombpnet.git
    # pip install -e chrombpnet

    # Q: Do we need to filter out any chromosome before the split? compare the results. 
    # TODO: need to be executed 5 times to get all the fold_0, fold_1, fold_2, fold_3, fold_4
    mkdir -p ./outputPath/splits/ 
    echo 'outputPrefix (-op) is ${outputPrefix}. chromSizes (-c) is ${chromSizes}. testChroms (-tcr) is ${testChroms}. validationChroms (-vcr) is ${validationChroms}.'
    chrombpnet prep splits -c ${chromSizes} -tcr ${testChroms} -vcr ${validationChroms} -op ./outputPath/splits/${outputPrefix}
    ls -l outputPath/splits/ > ls_files.txt
  }

  output {
    File response = stdout()
    File ls_output = "ls_files.txt"
    File splits = "./outputPath/splits/${outputPrefix}.json"
  }

  runtime {
    docker: 'kundajelab/chrombpnet:latest'
    memory: 5 + "GB"
    bootDiskSizeGb: 20
    disks: "local-disk 20 HDD"
  }
}

#  runtime {
#    cpu: '4'
#    memory: 50 + "GB"
#  }
#  runtime {
#    docker: 'kundajelab/chrombpnet:latest'
#    memory: 20 + "GB"
#  }

  # runtime {
        #       docker: 'kundajelab/chrombpnet:latest'
        #       memory: 50 + "GB"
        #       bootDiskSizeGb: 50
        #       disks: "local-disk 100 HDD"
        #       gpuType: "nvidia-tesla-v100"
        #       gpuCount: 1
        #       nvidiaDriverVersion: "450.51.05" 
        #       maxRetries: 1
  # }
#}

########################END OF TASK run_split_train_valid_test