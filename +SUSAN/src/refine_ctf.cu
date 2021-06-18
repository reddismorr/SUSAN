#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <getopt.h>
#include <unistd.h>

#include "io.h"
#include "refine_ctf.h"
#include "particles.h"
#include "tomogram.h"
#include "reference.h"
#include "refine_ctf_args.h"

void print_data_info(Particles&ptcls,Tomograms&tomos) {
    printf("\t\tAvailable particles:  %d.\n",ptcls.n_ptcl);
    printf("\t\tTomograms available:  %d.\n",tomos.num_tomo);
    printf("\t\tAvailabe projections: %d (max).\n",tomos.num_proj);
}

int main(int ac, char** av) {

    RefCtfAli::Info info;

    if( RefCtfAli::parse_args(info,ac,av) ) {
        RefCtfAli::print(info);
        PBarrier barrier(2);
        ParticlesRW ptcls(info.ptcls_in);
        Tomograms tomos(info.tomo_file);
        print_data_info(ptcls,tomos);
        StackReader stkrdr(&ptcls,&tomos,&barrier);
        CtfRefPool pool(&info,tomos.num_proj,ptcls.n_ptcl,stkrdr,info.n_threads);

        stkrdr.start();
        pool.start();

        stkrdr.wait();
        pool.wait();

        ptcls.save(info.ptcls_out);
    }
    else {
        fprintf(stderr,"Error parsing input arguments.\n");
        exit(1);
    }
	
    return 0;
}



