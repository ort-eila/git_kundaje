workflow MyWorkflow {
  input {
    File inputFile1
    File inputFile2
  }

  task MyTask {
    input {
      File input1 = inputFile1
      File input2 = inputFile2
    }

    command {
      # Your task command here that processes input1 and input2
      echo "Running MyTask with ${input1} and ${input2}"
    }

    output {
      File output_file = "output.txt"
    }

    runtime {
      docker: "ubuntu:latest" // Or specify an appropriate Docker container
    }
  }

  output {
    File final_output = MyTask.output_file
  }
}
