version 1.0
# chrombpnet pipeline \
#         -ibam ~/chrombpnet_tutorial/data/downloads/merged.bam \
#         -d "ATAC" \
#         -g ~/chrombpnet_tutorial/data/downloads/hg38.fa \
#         -c ~/chrombpnet_tutorial/data/downloads/hg38.chrom.sizes \
#         -p ~/chrombpnet_tutorial/data/peaks_no_blacklist.bed \
#         -n ~/chrombpnet_tutorial/data/output_negatives.bed \
#         -fl ~/chrombpnet_tutorial/data/splits/fold_0.json \
#         -b ~/chrombpnet_tutorial/bias_model/ENCSR868FGK_bias_fold_0.h5 \
#         -o ~/chrombpnet_tutorial/chrombpnet_model/
workflow wf_train_bias_factorized_model {
  input {
    File   yourBam
    String yourDataType
    File   yourGenome
    File   yourChromeSize
    File   yourPeaks
    File   yourNoPeaks
    File   yourFoldPath
    File   yourBiasModelPath
  }
  

  call run_train_bias_factorized_model_task {
    input: 
      ibam = yourBam,
      dataType = yourDataType,
      genome = yourGenome,
      chromeSize = yourChromeSize,
      peaks = yourPeaks,
      noPeaks = yourNoPeaks,
      foldPath = yourFoldPath,
      biasModelPath = yourBiasModelPath
  }
  output {
    File workflow_stdout_output = run_train_bias_factorized_model_task.response
    File workflow_ls_output = run_train_bias_factorized_model_task.ls_output
  }
}

#################END OF WORKFLOW

task run_train_bias_factorized_model_task {
  input {
    File    ibam
    String  dataType
    File    genome
    File    chromeSize
    File    peaks
    File    noPeaks
    File    foldPath
    File    biasModelPath
  }
  
  command {
    # cd /; mkdir chrombpnet
    # cd /chrombpnet
    # git clone https://github.com/kundajelab/chrombpnet.git
    # pip install -e chrombpnet

    mkdir outputPath
    # TODO: add the output and mapping to the table
    echo 'bam (-ibam) is ${ibam}. dataType (-d) is ${dataType}. genome (-g) ${genome}. ChromeSize (-c) ${chromeSize}. Peaks (-p) ${peaks}. NoPeaks (-n) ${noPeaks}. foldPath (-fl) ${foldPath}. biasModelPath (-b) ${biasModelPath}. '
    ls -l outputPath > ls_files.txt
    chrombpnet pipeline -ibam ${ibam} -d ${dataType} -g ${genome} -c ${chromeSize} -p ${peaks} -n ${noPeaks} -fl ${foldPath} -b ${foldPath} -o ./outputPath
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

########################END OF TASK run_train_bias_factorized_model_task