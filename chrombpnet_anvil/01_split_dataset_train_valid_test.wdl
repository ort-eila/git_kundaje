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
    chromSizesFiltered="${outputPath}/chrom.sizes.filtered"
    echo "chromSizesFiltered is ${chromSizesFiltered}"
    rm "$chromSizesFiltered"

    # Filter chromosomes
    echo "Filtering chromosomes..."
    # Extract rows with specified chromosomes
    echo "$chromosomesToInclude" | xargs -n 1 -I {} grep -w {} "$chromSizes" >> "$chromSizesFiltered" || true

    # Log the filtered chromosome sizes file
    echo "Filtered chromosome sizes file: ${chromSizesFiltered}"

    # List files in the output directory
    echo "Listing files in the output directory..."
    ls -l "${outputPath}/" > ls_files.txt

    head "$chromSizesFiltered"

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