# Variables
# ------------------------------------------------
variable "test_list" {
    type = list(string)
    default = ["whizlabs", "is", "awsome"]
}

variable "test_map" {
    type = map(string)
    default = {
        Name = "Juan"
        LastName = "Perez"
    }
}

variable "test_object_list" {
    type = list(object({        
        Name = string
        LastName = string
    }))
    default = [
        {
            Name = "Juan"
            LastName = "Perez"
        },
        {
            Name = "John"
            LastName = "Doe"
        }
    ]
}

# Outputs
# ------------------------------------------------

# loops and upper case, list of strings
output "loop_output_list" {
    value = [for s in var.test_list: upper(s)]
}

output "loop_output_map" {
    value = [for s in var.test_map: upper(s)]
}

output "loop_output_map_2" {
    value = [for k, v in var.test_map: "${k} is ${v}"]
}

output "loop_output_map_3" {
    value = {for k, v in var.test_map: k => upper(v)}
}

# loops and upper case, object of strings
output "loop_output_object" {
    value = {for s in var.test_list: s=> upper(s)}
}

# accesing to map value
output "value_map_1" {
    value = var.test_map.Name
}
output "value_map_2" {
    value = var.test_map["Name"]
}

# accessing to object list
output "value_object_list_1" {
    value = var.test_object_list[0].Name
}

output "value_object_list_all" {
    value = [for s in var.test_object_list : s]
}

output "value_object_list_all_last_names" {
    value = [for s in var.test_object_list : s.LastName]
}

output "value_object_list_all_last_names_splat" {
    value = var.test_object_list[*].LastName
}

output "x_heredoc_output" {
    value = <<-EOT
                
                Hello,
                World!
                EOT
}

output "x_heredoc_output_directives" {
    value = <<-EOT
            %{ for k,v in var.test_map ~}
            ${k} is ${v}
            %{endfor ~}
            EOT
}

output "x_root_path" { 
    value = path.root
}

output "x_current_path" { 
    value = path.cwd
}

output "x_module_path" { 
    value = path.module
}
output "x_workspace_name" { 
    value = terraform.workspace
}

output "x" {
    value = "\n"
}

output "x_backslashes" {
    value = "$${"
}

# References
# https://www.terraform.io/docs/language/expressions/index.html
# https://www.terraform.io/docs/configuration/variables.html