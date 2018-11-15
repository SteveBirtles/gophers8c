#version 430 core
#define NUMPARTICLES 2000
#define MAX_SPEED 100

layout (local_size_x = 32, local_size_y = 32) in;

layout (std140, binding = 0) buffer Pos {
  vec4 positions[];
};

layout (std140, binding = 1) buffer Vel {
  vec4 velocities[];
};

layout (std140, binding = 2) buffer Mass {
  float masses[];
};


void main() {

    float t = 0.01;

    uint index = gl_GlobalInvocationID.x + gl_GlobalInvocationID.y * gl_NumWorkGroups.x * gl_WorkGroupSize.x;

	if(index > NUMPARTICLES) {
	    return;
    }

    float d;
    for (int otherIndex = 0; otherIndex < NUMPARTICLES; otherIndex++) {
        if (index == otherIndex) {
            continue;
        }
        d = distance(positions[index], positions[otherIndex]);
        if (d < 1) {
            vec4 n = normalize(positions[index] - positions[otherIndex]);
            positions[index] -= n;
            positions[otherIndex] += n;
        } else if (d < 100) {
            velocities[index] -= masses[index] * masses[otherIndex] * (positions[index] - positions[otherIndex]) / pow(d, 2);
        }

    }

    float speed = length(velocities[index]);
    if (speed > MAX_SPEED) {
        velocities[index] *= MAX_SPEED / speed;
    }

    positions[index] += t * velocities[index];

}