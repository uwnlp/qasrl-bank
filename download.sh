#!/bin/bash

# If files are already present, will do nothing. If not, will prompt the user to confirm the download.

if [ ! -e "data/qasrl-v2/" ]
then
    read -p $'Data: QASRL Bank 2.0\nSource: Large-Scale QA-SRL Parsing. Nicholas Fitzgerald, Julian Michael, Luheng He, and Luke Zettlemoyer, ACL 2018.\nDownload? [y/N] ' answer
    case ${answer:0:1} in
        y|Y )
            curl -o data/qasrl-v2.tar http://qasrl.org/data/qasrl-v2.tar
            tar xf data/qasrl-v2.tar -C data
            rm data/qasrl-v2.tar
            ;;
        * )
            echo "Skipped downloading QA-SRL Bank 2.0. Run download.sh again if you change your mind."
            ;;
    esac
fi