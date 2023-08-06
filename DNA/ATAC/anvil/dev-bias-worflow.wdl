version 1.0


workflow ChrombpnetBias {
  input {
    File   yourBam
    String yourName
    String yourDataType
    File   yourGenome
    File   yourChromeSize
    File   yourPeaks
    File   yourNoPeaks
    File   yourFoldPath
    File   yourBiasModelPath
  }
  

  call run_bias_task {
    input: 
      name = yourName,
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
    File workflow_stdout_output = run_bias_task.response
    File workflow_ls_output = run_bias_task.ls_output
  }
}

#################END OF WORKFLOW

task run_bias_task {
  input {
    String  name
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
    echo 'hello ${name}! bam (-ibam) is ${ibam}. dataType (-d) is ${dataType}. genome (-g) ${genome}. ChromeSize (-c) ${chromeSize}. Peaks (-p) ${peaks}. NoPeaks (-n) ${noPeaks}. foldPath (-fl) ${foldPath}. biasModelPath (-b) ${biasModelPath}. '
    ls -l outputPath > ls_files.txt
    chrombpnet pipeline -ibam ${ibam} -d ${dataType} -g ${genome} -c ${chromeSize} -p ${peaks} -n ${noPeaks} -fl ${foldPath} -b ${foldPath} -o ./outputPath
  }

  output {
    File response = stdout()
    File ls_output = "ls_files.txt"
  }

  runtime {
    docker: 'kundajelab/chrombpnet:latest'
    memory: 100 + "GB"
    bootDiskSizeGb: 100
    disks: "local-disk 250 HDD"
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

########################END OF TASK run_bias_task