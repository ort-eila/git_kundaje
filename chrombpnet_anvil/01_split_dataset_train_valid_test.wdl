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
    File workflow_splits_json = run_split_train_valid_test.splits
    File workflow_chromSizesFiltered = run_split_train_valid_test.chromSizesFiltered
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

    echo chromosomesToInclude is ~{chromosomesToInclude}

    # Filter chromosomes using a loop
    echo "Filtering chromosomes..."
    for chrom in $(echo "~{chromosomesToInclude}" | tr ' ' '\n'); do
      echo "Processing chromosome: $chrom"
      grep -w "$chrom" "~{chromSizes}" >> "${chromSizesFiltered}" || true
    done

    # Log the filtered chromosome sizes file
    echo "Filtered chromosome sizes file: ${chromSizesFiltered}"
  
    # Run chrombpnet command
    # Echo example
    echo "chrombpnet prep splits -c ${chromSizesFiltered} -tcr ~{testChroms} -vcr ~{validationChroms} -op ${outputPath}/~{outputPrefix}"
    # touch ./outputPath/splits/~{outputPrefix}.json
    # chrombpnet prep splits -c hg38.chrom.sizes -tcr chr1 chr3 chr6 -vcr chr8 chr20 -op ./outputPath/splits/fold_0
    chrombpnet prep splits -c ${chromSizesFiltered} -tcr ~{testChroms} -vcr ~{validationChroms} -op ${outputPath}/~{outputPrefix}

    # List files in the output directory
    echo "Listing files in the output directory..."
    ls -l ${outputPath} > ls_files.txt
  >>>

  output {
    File splits = "./outputPath/splits/${outputPrefix}.json"
    File chromSizesFiltered = "./outputPath/splits/chrom.sizes.filtered"
    File response = stdout()
    File ls_output = "ls_files.txt"
  }

  runtime {
    docker: 'kundajelab/chrombpnet:latest'
    memory: 4 + "GB"
    bootDiskSizeGb: 20
    disks: "local-disk 50 HDD"
  }
}