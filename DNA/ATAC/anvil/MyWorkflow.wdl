workflow MyWorkflow {
  input {
    File inputFile1
    File inputFile2
  }

  call PrintFileContents {
    input:
      inputFile1 = inputFile1,
      inputFile2 = inputFile2
  }
}

task PrintFileContents {
  File inputFile1
  File inputFile2

  command {
    # Read and print the content of inputFile1
    echo "Content of inputFile1:"
    cat "${inputFile1}"

    # Read and print the content of inputFile2
    echo "Content of inputFile2:"
    cat "${inputFile2}"
  }

  output {
    File tempOutput = write_lines(["Content of inputFile1:", "${inputFile1}", "", "Content of inputFile2:", "${inputFile2}"])
  }

  runtime {
    docker: "ubuntu:latest" // Or specify an appropriate Docker container for 'cat' and 'echo' commands
  }
}
