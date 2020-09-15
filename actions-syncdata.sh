#!/bin/bash

function check-env() {
    echo -e "\033[34mREP_BASE_PROD \033[0m: ${REP_BASE_PROD:?}"
}

function check-dirs() {
    if [ -d $REP_BASE_PROD ]; then
        echo -e "found\033[32m valid REP_BASE_PROD \033[0m: ${REP_BASE_PROD:?}"
    else 
        echo -e "\033[31m REP_BASE_PROD \033[0m: ${REP_BASE_PROD}"
        exit 1
    fi
}

function sync-rev-arc() {
    # see https://www.isdc.unige.ch/integral/archive#DataRelease

    orbit=${1:?please provide orbit as first argument}
    filter=${2:-}

    mkdir -pv $REP_BASE_PROD/scw/$orbit
    mkdir -pv $REP_BASE_PROD/aux/adp/$orbit.001

    set -x

    rsync -lrtv --include '**'${filter}'**' --exclude '*'  isdcarc.unige.ch::arc/rev_3/scw/${orbit}/ $REP_BASE_PROD/scw/$orbit/
    rsync -lrtv --include '**'$orbit'**' --exclude '*' isdcarc.unige.ch::arc/rev_3/aux/adp/ $REP_BASE_PROD/aux/adp
    rsync -lrtv isdcarc.unige.ch::arc/rev_3/aux/adp/ref/ $REP_BASE_PROD/aux/adp/ref/
}

function sync-rev-cons() {
    # see https://www.isdc.unige.ch/integral/archive#DataRelease

    orbit=${1:?please provide orbit as first argument}

    mkdir -pv $REP_BASE_PROD/scw/$orbit
    mkdir -pv $REP_BASE_PROD/aux/adp/$orbit.001

    rsync -lrtv isdcarc.unige.ch::arc/FTP/arc_distr/CONS/public/scw/${orbit}/ $REP_BASE_PROD/scw/$orbit/
    rsync -lrtv isdcarc.unige.ch::arc/FTP/arc_distr/CONS/public/aux/adp/$orbit.001/ $REP_BASE_PROD/aux/adp/$orbit.001/
    rsync -lrtv isdcarc.unige.ch::arc/FTP/arc_distr/CONS/public/aux/adp/ref/ $REP_BASE_PROD/aux/adp/ref/
}

function sync-rev-nrt() {
    # see https://www.isdc.unige.ch/integral/archive#DataRelease

    orbit=${1:?}
    mkdir -pv $REP_BASE_PROD_NRT/scw/$orbit
    mkdir -pv $REP_BASE_PROD_NRT/aux/adp/$orbit.000
    mkdir -pv $REP_BASE_PROD_NRT/aux/adp/$orbit.001

    rsync -lrtv isdcarc.unige.ch::arc/FTP/arc_distr/NRT/public/scw/${orbit}/ $REP_BASE_PROD/scw/$orbit/
    rsync -lrtv isdcarc.unige.ch::arc/FTP/arc_distr/NRT/public/aux/adp/$orbit.00*/ $REP_BASE_PROD/aux/adp
    rsync -lrtv isdcarc.unige.ch::arc/FTP/arc_distr/NRT/public/aux/adp/ref/ $REP_BASE_PROD/aux/adp/ref/

    #rsync -avu isdc-in01:/isdc/pvphase/nrt/ops/scw/$orbit/ $REP_BASE_PROD_NRT/scw/$orbit/
    #rsync -avu isdc-in01:/isdc/pvphase/nrt/ops/aux/adp/$orbit.000/ $REP_BASE_PROD_NRT/aux/adp/$orbit.000
    #rsync -avu login01.astro.unige.ch:/isdc/arc/rev_3/aux/adp/ref/ $REP_BASE_PROD_NRT/aux/adp/ref/
}

function sync-rev() {
    # implementation of https://www.isdc.unige.ch/integral/archive#DataRelease

    orbit=${1:?}
    datalevel=${2:-arc}
    
    if [ "$datalevel" == "nrt" ]; then
        sync-rev-nrt $orbit
    elif [ "$datalevel" == "cons" ]; then
        sync-rev-cons $orbit
    elif [ "$datalevel" == "arc" ]; then
        sync-rev-arc $orbit
    fi
}

function sync-ic() {
    rsync -Lzrtv isdcarc.unige.ch::arc/FTP/arc_distr/ic_tree/prod/ $REP_BASE_PROD
}

check-env

$@
