#!/bin/bash

export SCRIPT="$( basename "${BASH_SOURCE[0]}" )"
export SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export WORKSPACE=${WORKSPACE:-$SCRIPTPATH/../workspace}

source $SCRIPTPATH/common.sh

export VM_MEMORY=${VM_MEMORY:-8192}
export VM_CPUS=${VM_CPUS:-4}

export BOSH_NON_INTERACTIVE=${BOSH_NON_INTERACTIVE:-true}

if [ ! -d $WORKSPACE ]; then
  mkdir -p $WORKSPACE
fi

cd $WORKSPACE

if [ ! -d bucc ]; then
 git clone https://github.com/starkandwayne/bucc.git
fi

echo "Setting VM MEMORY to $VM_MEMORY, VM_CPUS to $VM_CPUS"
sed -i "s/vm_memory: 4096/vm_memory: $VM_MEMORY/" $WORKSPACE/bucc/ops/cpis/virtualbox/vars.tmpl
sed -i "s/vm_cpus: 2/vm_cpus: $VM_CPUS/" $WORKSPACE/bucc/ops/cpis/virtualbox/vars.tmpl

$WORKSPACE/bucc/bin/bucc up --cpi virtualbox --lite --debug | tee $WORKSPACE/bucc_up.log
$WORKSPACE/bucc/bin/bucc env > $WORKSPACE/bosh_env.sh

echo "Adding routes, you may need to enter credentials"
$SCRIPTPATH/setup_bosh_swap.sh
$SCRIPTPATH/setup_bosh_routes.sh

