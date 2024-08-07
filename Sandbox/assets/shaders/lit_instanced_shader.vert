#version 460

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 color;
layout(location = 2) in vec3 normal;
layout(location = 3) in vec2 uv;
layout(location = 4) in vec3 tangent;

layout(location = 0) out vec3 v_position_world_space;
layout(location = 1) out vec3 v_color;
layout(location = 2) out vec3 v_normal_world_space;
layout(location = 3) out vec2 v_uv;

layout(location = 4) out vec4 v_position_light_space;
layout(location = 5) out mat3 v_tbn_matrix;

struct DirectionalLight {
  mat4 view_proj;

  vec4 color;
  vec4 direction;
};

struct ObjectData 
{
	mat4 model_matrix;
  vec4 color;
};

layout(set = 0, binding = 0) uniform SceneData {
  mat4 view;
  mat4 proj;

  uint dir_light_count;
  uint point_light_count;
  uint spot_light_count;
  uint area_light_count;
};

layout(std140, set = 0, binding = 1) readonly buffer DirectionalLights {
  DirectionalLight dir_lights[];
};

layout(std140, set = 0, binding = 5) readonly buffer objectData{
  ObjectData objects[];
};

// Descriptor set 3 is reserved for instanced object data
layout(std140, set = 3, binding = 0) readonly buffer InstancedObjectData{
  uint ids[];
};

void main()
{
  uint object_data_index = ids[gl_InstanceIndex];
	mat4 model_matrix = objects[object_data_index].model_matrix;

	v_position_world_space = vec3(model_matrix * vec4(position, 1.0f)); 
	v_color = color;

	v_uv = uv;
  
  // Calculate TBN
  vec3 T = normalize(vec3(model_matrix * vec4(tangent, 0.0)));
  vec3 N = normalize(vec3(model_matrix * vec4(normal, 0.0)));

  T = normalize(T - dot(T,N) * N);
  vec3 B = normalize(cross(normal, tangent));
  v_tbn_matrix = transpose(mat3(T, B, N));

	// v_normal_world_space = normalize(mat3(model_matrix) * normal); // For uniform scaled objects
	v_normal_world_space = normalize(mat3(transpose(inverse(model_matrix))) * normal); 

	v_position_light_space =  dir_lights[0].view_proj * vec4(v_position_world_space, 1.0f);
	gl_Position = proj * view * vec4(v_position_world_space, 1.0f);
}