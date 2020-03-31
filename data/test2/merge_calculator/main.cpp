#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cstddef>
#include "Vector3.h"
#include "Quaternion.h"

#define N_ROBOTS 14
#define N_STEPS 2700

#define PI 3.1415926

FILE *in[N_ROBOTS];
FILE *out1, *out2;

int n_steps;

char dir_base[200] = "";
char str_robots[N_ROBOTS][100] = {
	"drone1.csv",
	"drone2.csv",
	"drone3.csv",
	"drone4.csv",
	"pipuck1.csv",
	"pipuck2.csv",
	"pipuck3.csv",
	"pipuck4.csv",
	"pipuck5.csv",
	"pipuck6.csv",
	"pipuck7.csv",
	"pipuck8.csv",
	"pipuck9.csv",
	"pipuck10.csv",
};

Vector3 locs[N_ROBOTS][N_STEPS];
Quaternion dirs[N_ROBOTS][N_STEPS];
int ids[N_ROBOTS][N_STEPS];

int load_file()
{
	char filename[100];
	for (int i = 0; i < N_ROBOTS; i++)
	{
		strcpy(filename, dir_base); 
		strcat(filename, str_robots[i]); 
		in[i] = fopen(filename, "r");
	}

	for (int i = 0; i < N_ROBOTS; i++)
		if (in[i] == NULL) {printf("file %s open failed\n", str_robots[i]); return -1;}

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
			ids[i][j] = info;
		}
	}

	return 0;
}

int calc_data()
{
	out1 = fopen("merge_vns_number.txt", "w");
	if (out1 == NULL) {printf("result file generation failed\n"); return -1;}
	out2 = fopen("merge_robots_number.txt", "w");
	if (out2 == NULL) {printf("result file generation failed\n"); return -1;}

	for (int time = 0; time < n_steps; time++)
	{
		int vns_number = 0;
		int robots_number = 0;
		int index_record[N_ROBOTS+1];
		for (int i = 1; i <= N_ROBOTS; i++) index_record[i] = 0;

		for (int i = 0; i < N_ROBOTS; i++)
		{
			if ((ids[i][time] == 1) || (ids[i][time] == -1))
				vns_number++;
			index_record[ids[i][time]] = 1;
		}

		for (int i = 1; i <= N_ROBOTS; i++)
			if (index_record[i] == 1) robots_number++;

		fprintf(out1, "%d\n", vns_number);
		fprintf(out2, "%d\n", robots_number);
	}

	fclose(out1);
	fclose(out2);

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
