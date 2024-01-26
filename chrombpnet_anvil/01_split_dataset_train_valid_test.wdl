version 1.0

workflow wf_split_dataset_train_valid_test {
  input {
    String yourOutputPrefix
    File  yourChromSizes
    String yourTestChroms
    String yourValidationChroms
    String yourChromosomesToInclude
  }

  call run_split_train_valid_test {
    input:
      outputPrefix = yourOutputPrefix,
      chromSizes = yourChromSizes,
      testChroms = yourTestChroms,
      validationChroms = yourValidationChroms,
      chromosomesToInclude = yourChromosomesToInclude
  }

  output {
    File splits_json = run_split_train_valid_test.splits
    File workflow_stdout_output = run_split_train_valid_test.response
    File workflow_ls_output = run_split_train_valid_test.ls_output
  }
}

task run_split_train_valid_test {
  input {
    String outputPrefix
    File  chromSizes
    String testChroms
    String validationChroms
    String chromosomesToInclude
  }

  command <<<
    
    
    set -euo pipefail
    IFS=$'\n'  # Set field separator to newline

    
    # Create output directory
    outputPath="./outputPath/splits"
    mkdir -p "$outputPath"

    # Declare variables for clarity
    String chromSizesFiltered = "{outputPath}/chrom.sizes.filtered"

    # Filter chromosomes
    echo "Filtering chromosomes..."
    for chr in ${chromosomesToInclude}; do
      grep -x "${chr}" "${chromSizes}" >> "${chromSizesFiltered}"
    done

    # Log the filtered chromosome sizes file
    echo "Filtered chromosome sizes file: ${chromSizesFiltered}"

    # Run chrombpnet command
    echo "Running chrombpnet command..."
    chrombpnet prep splits -c "${chromSizesFiltered}" -tcr "${testChroms}" -vcr "${validationChroms}" -op "${outputPath}/${outputPrefix}"

    # List files in the output directory
    echo "Listing files in the output directory..."
    ls -l "${outputPath}/" > ls_files.txt

    # Log response from stdout
    echo "Logging response from stdout..."
    cat "${outputPath}/${outputPrefix}.json"
  >>>

  output {
    File splits = "./outputPath/splits/${outputPrefix}.json"
    File response = stdout()
    File ls_output = "./outputPath/splits/ls_files.txt"
  }

  runtime {
    docker: 'kundajelab/chrombpnet:latest'
    memory: 4 + "GB"
    bootDiskSizeGb: 20
    disks: "local-disk 50 HDD"
  }
}