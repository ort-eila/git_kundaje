version 1.0
# modisco motifs [-h] -i H5PY -n MAX_SEQLETS -op OUTPUT_PREFIX [-l N_LEIDEN] [-w WINDOW] [-v]

workflow wf_modisco_find_motifs {
  input {
    String yourExperiment
    Array [File] yourShap
    Int? yourMem_gb=16
    Int? yourMax_seqlets=25000
    Int? yourNumber_of_cpus=4
  }
  

  call run_modisco_find_motifs_task {
    input:
    experiment = yourExperiment,
    shap = yourShap,
    mem_gb = yourMem_gb,
    max_seqlets = yourMax_seqlets,
    number_of_cpus = yourNumber_of_cpus
  }
  output {
    File workflow_stdout_output = run_modisco_find_motifs_task.response
    File workflow_ls_output = run_modisco_find_motifs_task.ls_output
    Array[File] workflow_modisco_counts_motifs = run_modisco_find_motifs_task.modisco_counts_motifs
    File workflow_modisco_profile_h5 = run_modisco_find_motifs_task.modisco_profile_h5
    File workflow_modisco_counts_h5 = run_modisco_find_motifs_task.modisco_counts_h5
  }
}

#################END OF WORKFLOW

task run_modisco_find_motifs_task {
  input {
    String experiment
    Array [File] shap
    Int? mem_gb
    Int? max_seqlets
    Int? number_of_cpus
  }
  
  command {
    # cd /; mkdir chrombpnet
    # cd /chrombpnet
    # git clone https://github.com/kundajelab/chrombpnet.git
    # pip install -e chrombpnet

    mkdir outputPath
    echo 'experiment ${experiment}. shap ${shap}. mem_gb ${mem_gb}. max_seqlets ${max_seqlets}. number_of_cpus ${number_of_cpus}.'
    
    # tfmodisco-lite
    # modisco motifs -s ohe.npz -a shap.npz -n 2000 -o modisco_results.h5
    modisco motifs -s ohe.npz -a shap.npz -n  ${max_seqlets} -o modisco_results.h5
    # modisco motifs ${experiment} ${sep=',' shap} -n ${max_seqlets} -v
    cp -r /project/modisco_profile /cromwell_root/
    cp -r /project/modisco_counts /cromwell_root/
  }

  output {
    File response = stdout()
    File ls_output = "ls_files.txt"
    Array[File] modisco_profile_motifs = glob("modisco_profile/trimmed_logos/*")
    Array[File] modisco_counts_motifs = glob("modisco_counts/trimmed_logos/*")
    File modisco_profile_h5 = "modisco_profile/modisco_results.h5"
    File modisco_counts_h5 = "modisco_counts/modisco_results.h5"
  }

  runtime {
    docker: 'kundajelab/chrombpnet:latest'
    memory: ${mem_gb} + "GB"
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

########################END OF TASK run_modisco_find_motifs_task