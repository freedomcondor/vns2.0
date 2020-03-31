#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cstddef>
#include "Vector3.h"
#include "Quaternion.h"

#define N_ROBOTS 8
#define N_STEPS 11000

#define PI 3.1415926

FILE *in[N_ROBOTS];
FILE *out[N_ROBOTS];

int n_steps;

char dir_base[200] = "";
char str_robots[N_ROBOTS][100] = {
	"drone1",
	"drone2",
	"pipuck1",
	"pipuck2",
	"pipuck3",
	"pipuck4",
	"pipuck5",
	"pipuck6",
};
char csv_ext[5] = ".csv";
char result_ext[5] = ".txt";

double dis = 0.50;
double height= 1.5;
Vector3 goal_locs[N_ROBOTS] = {
	Vector3(),
	Vector3(-dis*2, 0, 0),

	Vector3(dis, dis, -height),
	Vector3(dis, -dis, -height),
	Vector3(-dis, -dis, -height),
	Vector3(-dis, dis, -height),

	Vector3(-dis*3, -dis, -height),
	Vector3(-dis*3, dis, -height),
};

Vector3 locs[N_ROBOTS][N_STEPS];
Quaternion dirs[N_ROBOTS][N_STEPS];
int ids[N_ROBOTS];

int load_file()
{
	char filename[100];
	for (int i = 0; i < N_ROBOTS; i++)
	{
		strcpy(filename, dir_base); 
		strcat(filename, str_robots[i]); 
		strcat(filename, csv_ext); 
		in[i] = fopen(filename, "r");
	}

	for (int i = 0; i < N_ROBOTS; i++)
		if (in[i] == NULL) {printf("file open failed\n"); return -1;}

	return 0;
}

int close_file()
{
	for (int i = 0; i < N_ROBOTS; i++)
		fclose(in[i]);
	return 0;
}

int read_data()
{
	int index;
	double info;
	double vx, vy, vz;
	double rx, ry, rz;

	for (int i = 0; i < N_ROBOTS; i++)
	{
		for (int j = 0; j < n_steps; j++)
		{
			fscanf(in[i], 
			       "%d,%lf,%lf,%lf,%lf,%lf,%lf,%lf\n", 
			       &index, &vx, &vy, &vz, &rz, &ry, &rx, &info
			      );

			locs[i][j].set(vx, vy, vz);
			dirs[i][j].set(Quaternion(1,0,0, rx * PI / 180) *
			               Quaternion(0,1,0, ry * PI / 180) *
			               Quaternion(0,0,1, rz * PI / 180)
			              );
		}
		ids[i] = info;
	}

	return 0;
}

int calc_data()
{
	char filename[100];
	for (int i = 0; i < N_ROBOTS; i++)
	{
		strcpy(filename, dir_base); 
		strcat(filename, str_robots[i]); 
		strcat(filename, result_ext); 
		out[i] = fopen(filename, "w");
	}

	for (int i = 0; i < N_ROBOTS; i++)
		if (out[i] == NULL) {printf("result file generation failed\n"); return -1;}

	int head_index;
	for (int i = 0; i < N_ROBOTS; i++)
		if (ids[i] == 1)
			head_index = i;

	for (int time = 0; time < n_steps; time++)
	{
		double sum = 0;
		for (int i = 0; i < N_ROBOTS; i++)
		{
			Vector3 relative_loc = 
				dirs[head_index][time].inv().toRotate(
						locs[i][time] - locs[head_index][time])
				;

			Vector3 error = relative_loc - goal_locs[ids[i]-1];
			fprintf(out[i], "%lf\n", error.len());
			sum += error.len();
			
			if (time == n_steps - 1)
				printf("%s %lf\n", str_robots[i], error.len());
		}
		sum /= N_ROBOTS;
		if (time == n_steps - 1)
			printf("total = %lf\n", sum);
	}

	for (int i = 0; i < N_ROBOTS; i++)
		fclose(out[i]);

	return 0;
}

int main(int argc, char *argv[])
{
	n_steps = atoi(argv[1]);
	printf("len = %d\n", n_steps);
	strcpy(dir_base, argv[2]);
	printf("csv_dir = %s\n", dir_base);

	if (load_file() != 0) return -1;

	read_data();

	calc_data();

	close_file();


	return 0;
}
