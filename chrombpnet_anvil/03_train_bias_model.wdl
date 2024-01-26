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

workflow wf_train_bias_model {
  input {
    String yourInputFileType
    File   yourBamFragTagSelection
    String yourDataType
    File   yourGenome
    File   yourChromeSize
    File   yourPeaks
    File   yourNoPeaks
    File   yourChrFoldPath
    Float  yourBiasThresholdFactor
    String yourFilePrefix
    Int? yourOutlierThreshold
    Int? yourNumSamples
    Int? yourInputlen
    Int? yourOutputlen
    Int? yourSeed
    Int? yourEpochs
    Int? yourEarlyStop
    Float? yourLearningRate
    String? yourTrack
    Int? yourFilters
    Int? yourNdilationLayers
    Int? yourMaxJitter
    Int? yourBatchSize
  }
  
  call run_train_bias_mode {
    input:
      inputFileType = yourInputFileType,
      bamFragTagSelection = yourBamFragTagSelection,
      dataType = yourDataType,
      genome = yourGenome,
      chromeSize = yourChromeSize,
      peaks = yourPeaks,
      noPeaks = yourNoPeaks,
      chrFoldPath = yourChrFoldPath,
      biasThresholdFactor = yourBiasThresholdFactor,
      filePrefix = yourFilePrefix,
      outlierThreshold = yourOutlierThreshold,
      numSamples = yourNumSamples,
      inputlen = yourInputlen,
      outputlen = yourOutputlen,
      seed = yourSeed,
      epochs = yourEpochs,
      earlyStop = yourEarlyStop,
      learningRate = yourLearningRate,
      track = yourTrack,
      filters = yourFilters,
      ndilationLayers = yourNdilationLayers,
      maxJitter = yourMaxJitter,
      batchSize = yourBatchSize
  }

  output {
    File workflow_stdout_output = run_train_bias_mode.response
    File workflow_ls_output = run_train_bias_mode.ls_output
  }
}

task run_train_bias_mode {
  input {
    String inputFileType
    File   bamFragTagSelection
    String dataType
    File   genome
    File   chromeSize
    File   peaks
    File   noPeaks
    File   chrFoldPath
    Float  biasThresholdFactor
    String filePrefix
    Int    outlierThreshold = -999
    Int    numSamples = -999
    Int    inputlen = -999
    Int    outputlen = -999
    Int    seed = -999
    Int    epochs = -999
    Int    earlyStop = -999
    Float  learningRate = -999.0
    String track = "na"
    Int    filters = -999
    Int    ndilationLayers = -999
    Int    maxJitter = -999
    Int    batchSize = -999
  }

  command <<<
    set -euo pipefail
    outputPath="outputPath/bias_model"
    mkdir -p $outputPath
  
    # Build the chrombpnet command
    command_string="chrombpnet bias pipeline -~{inputFileType} ~{bamFragTagSelection} -d \"~{dataType}\" -g ~{genome} -c ~{chromeSize} -p ~{peaks} -n ~{noPeaks} -fl ~{chrFoldPath} -b ~{biasThresholdFactor} -o $outputPath -fp ~{filePrefix}"

    # Function to add optional parameters to the command string
    add_parameter() {
      local param_name=$1
      local param_value=$2
      if [ "${param_value}" != "na" ] && [ "${param_value}" != -999 ] && [ "${param_value}" != -999.0 ]; then
        command_string="${command_string} -${param_name} ${param_value}"
      fi
    }

    # Add optional parameters to the command string
    add_parameter "oth" ~{outlierThreshold}
    add_parameter "num-samples" ~{numSamples}
    add_parameter "il" ~{inputlen}
    add_parameter "ol" ~{outputlen}
    add_parameter "s" ~{seed}
    add_parameter "e" ~{epochs}
    add_parameter "es" ~{earlyStop}
    add_parameter "l" ~{learningRate}
    add_parameter "track" ~{track}
    add_parameter "fil" ~{filters}
    add_parameter "dil" ~{ndilationLayers}
    add_parameter "j" ~{maxJitter}
    add_parameter "bs" ~{batchSize}

    echo "command_string for execution is ${command_string}"
    echo "${command_string}" > chrombpnet_command.sh
    chmod +x chrombpnet_command.sh

    ls -l ${outputPath} > ls_files.txt
    # Uncomment the line below to execute the chrombpnet command using the script file
    # ./chrombpnet_command.sh
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
