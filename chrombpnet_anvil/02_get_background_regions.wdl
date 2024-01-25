version 1.0

# chrombpnet prep nonpeaks -g ~/chrombpnet_tutorial/data/downloads/hg38.fa -p ~/chrombpnet_tutorial/data/peaks_no_blacklist.bed -c  ~/chrombpnet_tutorial/data/downloads/hg38.chrom.sizes -fl ~/chrombpnet_tutorial/data/splits/fold_0.json -br ~/chrombpnet_tutorial/data/downloads/blacklist.bed.gz -o ~/chrombpnet_tutorial/data/output

workflow wf_get_background_regions {
  input {
    File   yourGenome
    File   yourPeaks
    File   yourChromeSize
    File   yourBlackRegions
    File   yourFoldPath
  }
  

  call run_get_background_regions_test {
    input: 
      genome = yourGenome,
      peaks = yourPeaks,
      chromeSize = yourChromeSize,
      blackRegions = yourBlackRegions,
      foldPath = yourFoldPath
  }
  output {
    File workflow_stdout_output = run_get_background_regions_test.response
    File workflow_ls_output = run_get_background_regions_test.ls_output
  }
}

#################END OF WORKFLOW

task run_get_background_regions_test {
  input {
    File    genome
    File    peaks
    File    chromeSize
    File    blackRegions
    File    foldPath
  }
  
  command {
    # cd /; mkdir chrombpnet
    # cd /chrombpnet
    # git clone https://github.com/kundajelab/chrombpnet.git
    # pip install -e chrombpnet

    # Q: Is this making the right background? compare the results. output_negatives
    mkdir -p ./outputPath
    echo 'genome ${genome}. peaks ${peaks}. chromeSize ${chromeSize}. foldPath ${foldPath} '
    chrombpnet prep nonpeaks -g ${genome} -p ${peaks} -c ${chromeSize} -fl ${foldPath} -br ${blackRegions} -o ./outputPath
    ls ./outputPath
    ls ./outputPath -l > ls_files.txt
  }

  output {
    File response = stdout()
    File ls_output = "ls_files.txt"
  }

  runtime {
    docker: 'kundajelab/chrombpnet:latest'
    memory: 10 + "GB"
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

########################END OF TASK 