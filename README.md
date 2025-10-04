# Infra

## Description
A collection of scripts and instructions to help replace the Render Postgres instance. The instance expires monthly and several apps use it. Their databases need to be rec

## Usage
render.yaml: Start here with the overview: the instructions are included in the comments. The render.yaml blueprint itself creates the postgres instance from scratch
scripts/set-cs.sh.EXAMPLE: The example script comments step you through the configuration to create the app databases on the new instance
