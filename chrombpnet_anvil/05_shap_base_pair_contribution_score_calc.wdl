version 1.0

workflow wf_shap_base_pair_contribution_score_calc {
  input {
    File    yourGenome
    File    yourRegions
    File    yourModel
    String  yourExperiment
  }
  

  call run_shap_base_pair_contribution_score_calc {
    input: 
      genome = yourGenome,
      regions = yourRegions,
      model = yourModel,
      experiment = yourExperiment
  }
  output {
    File profile_shap_scores = run_shap_base_pair_contribution_score_calc.profile_shap_scores
    File interpreted_regions = run_shap_base_pair_contribution_score_calc.interpreted_regions
    File workflow_stdout_output = run_shap_base_pair_contribution_score_calc.response
    File workflow_ls_output = run_shap_base_pair_contribution_score_calc.ls_output
    File workflow_count_scores = run_shap_base_pair_contribution_score_calc.count_scores
  }
}

#################END OF WORKFLOW

task run_shap_base_pair_contribution_score_calc {
  input {
    File  genome
    File  regions
    File  model
    String  experiment
  }
  
  command {
    # cd /; mkdir chrombpnet
    # cd /chrombpnet
    # git clone https://github.com/kundajelab/chrombpnet.git
    # pip install -e chrombpnet

    # Vivian - provide inputs (with Eila)
    # TODO: check if you have this output: shap.npz
    # RUN shap on smaller region
    mkdir -p /project/shap_dir_peaks/
    echo "chrombpnet contribs_bw -g ${genome} -r ${regions} -m ${model} -o /project/shap_dir_peaks/${experiment} -p profile"
    chrombpnet contribs_bw -g ${genome} -r ${regions} -m ${model} -o /project/shap_dir_peaks/${experiment} 
    echo "copying all files to cromwell_root folder"
    cp -r /project/shap_dir_peaks/${experiment}.profile_scores.h5 /cromwell_root/${experiment}.profile_scores.h5
    cp -r /project/shap_dir_peaks/${experiment}.count_scores.h5 /cromwell_root/${experiment}.count_scores.h5
    cp -r /project/shap_dir_peaks/${experiment}.interpreted_regions.bed /cromwell_root/${experiment}.interpreted_regions.bed
    ls -l /project/shap_dir_peaks/ > ls_files.txt
  }

  output {
    File response = stdout()
    File profile_shap_scores = "${experiment}.profile_scores.h5"
		File interpreted_regions = "${experiment}.interpreted_regions.bed"
    File count_scores = "${experiment}.count_scores.h5"
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

########################END OF TASK wf_shap_base_pair_contribution_score_calc