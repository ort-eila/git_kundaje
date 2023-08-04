version 1.0

workflow chrombpnet_bias {
	input {
    File   input_bam_file
    String data_type
    File   genome_fa_file
    File   chrome_size_file
    File   peaks_file
    File   non_peaks_file
    String chr_fold_path
    String bias_threshold_factor
    String output_dir
    String file_prefix_str
    File   model_file
    String experiment_str
	}

	call run_bias_task {
	  input:
      input_bam_file = input_bam_file,
      data_type = data_type,
      genome_fa_file = genome_fa_file,
      chrome_size_file = chrome_size_file,
      peaks_file = peaks_file,
      non_peaks_file = non_peaks_file,
      chr_fold_path = chr_fold_path,
      bias_threshold_factor = bias_threshold_factor,
      output_dir = output_dir,
      file_prefix_str = file_prefix_str,
      model_file = model_file,
      experiment_str = experiment_str
	}
	# output {
	#   #bias model that trains on the observed accessibility in non peak regions
  #   File models_bias_h5 = "${experiment_str}.bias.h5"
  #   # Train and validation loss per epoch 
  #   File logs_bias_log = "${experiment_str}.bias.log"
	# }
}



#  runtime {
#    docker: 'kundajelab/chrombpnet:latest'
#    memory: 50 + "GB"
#    bootDiskSizeGb: 50
#    disks: "local-disk 100 HDD"
#    gpuType: "nvidia-tesla-v100"
#    gpuCount: 1
#    nvidiaDriverVersion: "450.51.05" 
#    maxRetries: 1
#    }

