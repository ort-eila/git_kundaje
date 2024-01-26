version 1.0
# modisco motifs [-h] -i H5PY -n MAX_SEQLETS -op OUTPUT_PREFIX [-l N_LEIDEN] [-w WINDOW] [-v]

workflow wf_modisco_find_motifs {
  input {
    File yourModel
    Int yourMax_seqlets
  }
  

  call run_modisco_find_motifs_task {
    input:
      model = yourModel,
      max_seqlets = yourMax_seqlets
  }


  output {
    File workflow_stdout_output = run_modisco_find_motifs_task.response
    File workflow_modisco_h5 = run_modisco_find_motifs_task.modisco_h5
  }
}

#################END OF WORKFLOW

task run_modisco_find_motifs_task {
  input {
    File model
    Int max_seqlets
  }
  
  command {
    mkdir outputPath    
    # tfmodisco-lite
    modisco motifs -i ${model} -n  ${max_seqlets} -o ./outputPath/modisco_results.h5
  }

  output {
    File response = stdout()
    File modisco_h5 = "./outputPath/modisco_results.h5"
  }

  runtime {
    docker: 'kundajelab/chrombpnet:latest'
    bootDiskSizeGb: 100
    disks: "local-disk 250 HDD"
  }
}

