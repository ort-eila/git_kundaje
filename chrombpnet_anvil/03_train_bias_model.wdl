version 1.0
# chrombpnet bias pipeline \
#         -ibam ~/chrombpnet_tutorial/data/downloads/merged.bam \
#         -d "ATAC" \
#         -g ~/chrombpnet_tutorial/data/downloads/hg38.fa \
#         -c ~/chrombpnet_tutorial/data/downloads/hg38.chrom.sizes \
#         -p ~/chrombpnet_tutorial/data/peaks_no_blacklist.bed \
#         -n ~/chrombpnet_tutorial/data/output_negatives.bed \
#         -fl ~/chrombpnet_tutorial/data/splits/fold_0.json \
#         -b 0.5 \
#         -o ~/chrombpnet_tutorial/bias_model/ \
#         -fp k562 \
# The command above outputs 

# TODO: duplicate yourOutlierThreshold for other optional parameters
# TODO: map the output to the tables (Vivek)
workflow wf_train_bias_model {
  input {
    String yourExecutionOption
    File   yourBamFragTagSelection
    String yourDataType
    File   yourGenome
    File   yourChromeSize
    File   yourPeaks
    File   yourNoPeaks
    File   yourChrFoldPath
    Float  yourBiasThresholdFactor
    String yourFilePrefix
    Float? yourOutlierThreshold
  }
  
  call run_train_bias_mode {
    input:
      executionOption = yourExecutionOption,
      bamFragTagSelection = yourBamFragTagSelection,
      dataType = yourDataType,
      genome = yourGenome,
      chromeSize = yourChromeSize,
      peaks = yourPeaks,
      noPeaks = yourNoPeaks,
      chrFoldPath = yourChrFoldPath,
      biasThresholdFactor = yourBiasThresholdFactor,
      filePrefix = yourFilePrefix,
      outlierThreshold = yourOutlierThreshold
  }

  output {
    File workflow_stdout_output = run_train_bias_mode.response
    File workflow_ls_output = run_train_bias_mode.ls_output
    # TODO: vivek, what is the output expected. and map it to the table
  }
}

task run_train_bias_mode {
  input {
    String executionOption
    File   bamFragTagSelection
    String dataType
    File   genome
    File   chromeSize
    File   peaks
    File   noPeaks
    File   chrFoldPath
    Float  biasThresholdFactor
    String filePrefix
    Float outlierThreshold = -999  # Set a default value of null
  }

  command <<<
    mkdir -p outputPath/bias_model
    # TODO: check dataType quotes
    # defaultOutlierThreshold=$(/bin/bash -c "chrombpnet bias pipeline -oth | grep 'OUTLIER_THRESHOLD:' | awk '{print \$2}' ")
    
    # Build the chrombpnet command
    command_string = "chrombpnet bias pipeline -~{executionOption} ~{bamFragTagSelection} -d \"~{dataType}\" -g ~{genome} -c ~{chromeSize} -p ~{peaks} -n ~{noPeaks} -fl ~{chrFoldPath} -b ~{biasThresholdFactor} -o outputPath/bias_model -fp ~{filePrefix}"

    # Include -oth option only if outlierThreshold is not empty
    if [ ~{outlierThreshold} -ne -999 ]; then
      command_string="${command_string} -oth ~{outlierThreshold}"
      echo "${command_string}"
    fi

    echo "${command_string}" > chrombpnet_command.sh
    chmod +x chrombpnet_command.sh

    # Execute the chrombpnet command using the script file
    ./chrombpnet_command.sh

    touch ls_files.txt
  >>>


  output {
    File response = stdout()
    File ls_output = "ls_files.txt"
  }

  runtime {
    docker: 'kundajelab/chrombpnet:latest'
    memory: 50 + "GB"
    bootDiskSizeGb: 50
    disks: "local-disk 100 HDD"
    gpuType: "nvidia-tesla-v100"
    gpuCount: 1
    nvidiaDriverVersion: "450.51.05" 
    maxRetries: 1
  }
}
