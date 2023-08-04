version 1.0

task run_bias {
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
  command {
		#create data directories and download scripts
		# cd /; mkdir my_scripts
		# cd /my_scripts
		# mkdir /project/
		# mkdir /project/shap_dir_peaks/
		# git clone --depth 1 --branch master https://github.com/kundajelab/chrombpnet.git

    echo "1. input_bam_file is ${input_bam_file}
    echo "2. data_type is ${data_type}
    echo "3. genome_fa_file is ${genome_fa_file}
    echo "4. chrome_size_file is ${chrome_size_file}
    echo "5. peaks_file is ${peaks_file}
    echo "6. non_peaks_file is ${non_peaks_file}
    echo "7. chr_fold_path is ${chr_fold_path}
    echo "8. bias_threshold_factor is ${bias_threshold_factor}
    echo "9. output_dir is ${output_dir}
    echo "10. file_prefix_str is ${file_prefix_str}
    echo "11. model_file is ${model_file}
    echo "12. experiment_str is ${experiment_str}
	}
	# task end
} 

