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
    File   yourBamFragTagSelection
    String yourDataType
    File   yourGenome
    File   yourChromeSize
    File   yourPeaks
    File   yourNoPeaks
    File   yourChrFoldPath
    Float  yourBiasThresholdFactor
    String yourFilePrefix
    String yourExecutionOption
  }
  

  call run_train_bias_mode {
    input: 
      bamFragTagSelection = yourBamFragTagSelection,
      dataType = yourDataType,
      genome = yourGenome,
      chromeSize = yourChromeSize,
      peaks = yourPeaks,
      noPeaks = yourNoPeaks,
      chrFoldPath = yourChrFoldPath,
      biasThresholdFactor = yourBiasThresholdFactor,
      filePrefix = yourFilePrefix,
      executionOption = yourExecutionOption

  }
  output {
    File workflow_stdout_output = run_train_bias_mode.response
    File workflow_ls_output = run_train_bias_mode.ls_output
  }
}

#################END OF WORKFLOW

task run_train_bias_mode {
  input {
    File   bamFragTagSelection
    String dataType
    File   genome
    File   chromeSize
    File   peaks
    File   noPeaks
    File   chrFoldPath
    Float  biasThresholdFactor
    String filePrefix
    String executionOption
  }
  
  command {
    # cd /; mkdir chrombpnet
    # cd /chrombpnet
    # git clone https://github.com/kundajelab/chrombpnet.git
    # pip install -e chrombpnet

    mkdir -p outputPath/bias_model
    # TODO: check dataType quotes
    echo 'chrombpnet bias pipeline  -ibam ${ibam} -d "${dataType}" -g ${genome} -c ${chromeSize} -p ${peaks} -n ${noPeaks} -fl ${chrFoldPath} -b ${biasThresholdFactor} -o outputPath/bias_model -fp ${filePrefix} '
    ls -l outputPath/bias_model > ls_files.txt
    # TODO: add default values.
    # TODO: missing output file: the bias model folder. expose a report. + mapping to the table Vivek (copy for other scripts - Eila)
    chrombpnet bias pipeline \
    -${executionOption} ${bamFragTagSelection} \
    -d "${dataType}" \
    -g ${genome} \
    -c ${chromeSize} \
    -p ${peaks} \
    -n ${noPeaks} \
    -fl ${chrFoldPath} \
    -b ${biasThresholdFactor} \
    -o outputPath/bias_model \
    -fp ${filePrefix} \
  }

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

########################END OF TASK