version 1.0

workflow wf_shap_base_pair_contribution_score_calc {
  input {
    File    yourGenome
    File    yourRegions
    File    yourModel
    File    yourChromSizes
    String  yourExperiment
  }
  
  call run_shap_base_pair_contribution_score_calc {
    input: 
      genome = yourGenome,
      regions = yourRegions,
      model = yourModel,
      chromSizes = yourChromSizes,
      experiment = yourExperiment
  }
  output {
    File workflow_stdout_output = run_shap_base_pair_contribution_score_calc.response
    File workflow_ls_output = run_shap_base_pair_contribution_score_calc.ls_output
  }
}

task run_shap_base_pair_contribution_score_calc {
  input {
    File  genome
    File  regions
    File  model
    File  chromSizes
    String  experiment
  }
  
  command {
    mkdir -p outputPath
    ls -l outputPath > ls_files.txt
    echo ${experiment}
    echo "chrombpnet contribs_bw -g ${genome} -r ${regions} -m ${model} -c ${chromSizes} -op ./outputPath
    chrombpnet contribs_bw -g ${genome} -r ${regions} -m ${model} -c ${chromSizes} -op ./outputPath
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
