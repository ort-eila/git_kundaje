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

	call run_bias {
	  input:
            ibam = input_bam_file,
            d_str = data_type,
            g_file = genome_fa_file,
            c_file = chrome_size_file,
            p_file = peaks_file,
            n_file = non_peaks_file,
            fl_str = chr_fold_path,
            b_str = bias_threshold_factor,
            o_str = output_dir,
            fp_str = file_prefix_str,
            model_file = model_file,
            experiment_str = experiment_str
	}
	output {
	  #bias model that trains on the observed accessibility in non peak regions
          File models_bias_h5 = "${experiment_str}.bias.h5"
          #Train and validation loss per epoch 
          File logs_bias_log = "${experiment_str}.bias.log"
	}
}

task run_bias {
  input {
    File ibam
    String d_str
    File g_file 
    File c_file
    File p_file
    File n_file
    String fl_str
    String b_str
    String o_str
    String fp_str
    File model_file
    String experiment_str
  }	
  command {
		#create data directories and download scripts
#		cd /; mkdir my_scripts
#		cd /my_scripts
#		mkdir /project/
#		mkdir /project/shap_dir_peaks/
#		git clone --depth 1 --branch master https://github.com/kundajelab/chrombpnet.git

		##bias

		#echo "python  ${g_file} -r ${p_file} -m ${model_file} -o /project/shap_dir_peaks/${experiment_str} "
        echo "1. ibam is ${ibam}
		echo "2. copying all files to cromwell_root folder"
	
	}
	
#  output {
#    #bias model that trains on the observed accessibility in non peak regions
#    File models_bias_h5 = "${experiment_str}.bias.h5"
#    #Train and validation loss per epoch 
#    File logs_bias_log = "${experiment_str}.bias.log"
#    }

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
}

