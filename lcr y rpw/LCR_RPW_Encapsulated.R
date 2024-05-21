# Load required libraries
library(igraph)

# Read the file
file_path <- "instance_n=100_1.alb"  # Update the path accordingly
data <- readLines(file_path)

# Find indices of sections
tasks_idx <- which(data == "<number of tasks>") + 1
cycle_idx <- which(data == "<cycle time>") + 1
times_idx <- which(data == "<task times>") + 1
relations_idx <- which(data == "<precedence relations>") + 1
end_idx <- which(data == "<end>") - 1

# Extract data based on found indices
number_of_tasks <- as.integer(data[tasks_idx])
cycle_time <- as.integer(data[cycle_idx])
task_times_lines <- data[times_idx:(times_idx + number_of_tasks - 1)]
precedence_relations <- data[relations_idx:end_idx]

# Parse task times
task_times <- strsplit(task_times_lines, " ")
task_times <- setNames(object = sapply(task_times, function(x) as.integer(x[2])), nm = sapply(task_times, function(x) as.integer(x[1])))

# Parse precedence relations and convert to matrix
edges <- strsplit(precedence_relations, ",")
edges_matrix <- do.call(rbind, lapply(edges, function(x) as.numeric(x)))
colnames(edges_matrix) <- c("Predecessor", "Subsequent")

# Initialize node list
nodes <- vector("list", number_of_tasks)
names(nodes) <- names(task_times)

# Assign task times to each node
for (i in names(nodes)) {
  nodes[[i]] <- list(task_time = task_times[[i]], predecessors = integer(0), successors = integer(0))
}

# Assign predecessors and successors
for (row in seq_len(nrow(edges_matrix))) {
  predecessor <- as.character(edges_matrix[row, "Predecessor"])
  subsequent <- as.character(edges_matrix[row, "Subsequent"])
  nodes[[predecessor]]$successors <- c(nodes[[predecessor]]$successors, subsequent)
  nodes[[subsequent]]$predecessors <- c(nodes[[subsequent]]$predecessors, predecessor)
}

# Set 0 for tasks with no predecessors or successors
for (i in names(nodes)) {
  if (length(nodes[[i]]$predecessors) == 0) {
    nodes[[i]]$predecessors <- 0
  }
  if (length(nodes[[i]]$successors) == 0) {
    nodes[[i]]$successors <- 0
  }
}

#
#
# Nodos cargados y correctamente asignados en variable 'nodes'
#
#

# Function to recursively calculate the weight of a task
calculate_weight_recursively <- function(task, nodes, weights) {
  if (weights[task] != 0) {  # If already calculated, return the stored weight
    return(weights[task])
  }
  # Base weight is the task's own time
  total_weight <- nodes[[task]]$task_time
  successors <- nodes[[task]]$successors
  if (successors[1] != "0") {
    for (succ in successors) {
      if (succ != "0") {
        # Recursively calculate the weight of each successor
        total_weight <- total_weight + calculate_weight_recursively(succ, nodes, weights)
      }
    }
  }
  weights[task] <- total_weight  # Store calculated weight to avoid recalculations
  return(total_weight)
}

calculate_positional_weights <- function(nodes) {
  weights <- rep(0, length(nodes))
  names(weights) <- names(nodes)
  
  # Trigger recursive calculation for each task
  for (task in names(nodes)) {
    weights[task] <- calculate_weight_recursively(task, nodes, weights)
  }
  
  # Print each task's weight for debugging
  for (task in names(weights)) {
    print(paste("Task:", task, "Weight:", weights[task]))
  }
  
  return(weights)
}

# Function to check if all predecessors are completed
all_predecessors_assigned <- function(task, assigned_tasks) {
  predecessors <- nodes[[task]]$predecessors
  
  # Handling the case where no predecessors are present or only '0' is listed
  if (length(predecessors) == 1 && predecessors == "0") {
    return(TRUE)  # No predecessors, thus assignable
  }
  
  # Return TRUE if all predecessors are in the list of assigned tasks
  all_assigned <- all(predecessors %in% assigned_tasks)
  # print(paste("Task:", task, "Predecessors:", paste(predecessors, collapse=", "), "All assigned:", all_assigned))
  return(all_assigned)
}

perform_LCR <- function(nodes, cycle_time) {
  workstations <- list()
  current_workstation <- list(tasks = character(), time_remaining = cycle_time)
  available_tasks <- names(nodes)
  all_assigned_tasks <- character()  # Maintain a separate list of all assigned tasks for easy reference
  
  while (length(available_tasks) > 0) {
    # Filter tasks with all predecessors assigned
    assignable_tasks <- available_tasks[sapply(available_tasks, function(t) all_predecessors_assigned(t, all_assigned_tasks))]
    
    if (length(assignable_tasks) > 0) {
      # Sort by task time descending
      assignable_tasks <- assignable_tasks[order(-sapply(assignable_tasks, function(t) nodes[[t]]$task_time))]
      
      # Try to assign the largest eligible task
      task_assigned <- FALSE
      for (task in assignable_tasks) {
        task_time <- nodes[[task]]$task_time
        if (current_workstation$time_remaining >= task_time) {
          current_workstation$tasks <- c(current_workstation$tasks, task)
          current_workstation$time_remaining <- current_workstation$time_remaining - task_time
          available_tasks <- setdiff(available_tasks, task)
          all_assigned_tasks <- c(all_assigned_tasks, task)
          task_assigned <- TRUE
          break
        }
      }
    }
    
    if (!task_assigned) {
      if (length(current_workstation$tasks) > 0) {
        workstations[[length(workstations) + 1]] <- current_workstation
        current_workstation <- list(tasks = character(), time_remaining = cycle_time)
      } else {
        break
      }
    }
  }
  
  # Add the last workstation if it has tasks
  if (length(current_workstation$tasks) > 0) {
    workstations[[length(workstations) + 1]] <- current_workstation
  }
  
  return(workstations)
}

perform_RPW <- function(nodes, cycle_time) {
  weights <- calculate_positional_weights(nodes)
  sorted_tasks <- names(sort(weights, decreasing = TRUE))
  
  workstations <- list()
  current_workstation <- list(tasks = character(), time_remaining = cycle_time)
  available_tasks <- names(nodes)
  all_assigned_tasks <- character()
  
  while (length(available_tasks) > 0) {
    assignable_tasks <- sorted_tasks[sapply(sorted_tasks, function(t) all_predecessors_assigned(t, all_assigned_tasks) && t %in% available_tasks)]
    
    if (length(assignable_tasks) > 0) {
      task_assigned <- FALSE
      for (task in assignable_tasks) {
        task_time <- nodes[[task]]$task_time
        if (current_workstation$time_remaining >= task_time) {
          current_workstation$tasks <- c(current_workstation$tasks, task)
          current_workstation$time_remaining <- current_workstation$time_remaining - task_time
          available_tasks <- setdiff(available_tasks, task)
          all_assigned_tasks <- c(all_assigned_tasks, task)
          task_assigned <- TRUE
          break
        }
      }
      
      if (!task_assigned) {
        workstations[[length(workstations) + 1]] <- current_workstation
        current_workstation <- list(tasks = character(), time_remaining = cycle_time)
      }
    } else {
      break  # If no tasks can be assigned, exit the loop
    }
  }
  
  if (length(current_workstation$tasks) > 0) {
    workstations[[length(workstations) + 1]] <- current_workstation
  }
  
  return(workstations)
}

# Call LCR function
LCR_workstations <- perform_LCR(nodes, cycle_time)
print(LCR_workstations)

# Call RPW function
RPW_workstations <- perform_RPW(nodes, cycle_time)
print(RPW_workstations)

#
# GRAPH
#
edges <- lapply(edges, function(x) as.numeric(x))
g <- graph_from_edgelist(do.call(rbind, edges), directed = TRUE)
# Using as tree layout
par(mar=c(0,0,5,0))  # Adjust margins as needed
plot(g, layout=layout_as_tree(g), edge.arrow.size=0.5, vertex.size=0, vertex.label=names(V(g)), main="Task Precedence Graph Tree")
