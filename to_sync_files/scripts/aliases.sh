# MAVEN
function mvnrun () {
  echo mvn $@
  eval mvn $@
}
export MAVEN_THREADS=0.75C
alias mci="mvnrun clean install -Dmaven.test.skip=true -o -T $MAVEN_THREADS $@"
alias mcp="mvnrun clean package -Dmaven.test.skip=true -o -T $MAVEN_THREADS $@"
alias mi="mvnrun install -DskipTests -o -T $MAVEN_THREADS $@"
alias mp="mvnrun package -DskipTests -o -T $MAVEN_THREADS $@"
alias mcheck="mvnrun checkstyle:checkstyle -o -T $MAVEN_THREADS $@"

 # BDD
alias bdd="mvn clean verify -Dwebdriver.base.url=http://localhost:8888 -Pcurrent -o"
function rbdd() {
	mvn thucydides:aggregate;
	google-chrome target/site/thucydides/index.html;
}

 # Lille
function mil () {
	mvnrun -o -T $MAVEN_THREADS $@ install -Pdev,sdm -DskipTests -Dcheckstyle.skip=true -Dgwt.compiler.skip=true -DuseIncrementalCompilation=false
    # -DuseIncrementalCompilation=false mvn stupid bug
	aplay ~/Music/sounds/wc3sfx-orc-peon/PeonYes3.wav
}
function milg () {
	mvnrun -o -T $MAVEN_THREADS $@ install -Pdev,sdm -DskipTests -Dcheckstyle.skip=true -DuseIncrementalCompilation=false;
	aplay ~/Music/sounds/wc3sfx-orc-peon/PeonYes3.wav;
}
noCheckstyle="-Dcheckstyle.skip=true"
gwtOpts="-Dgwt.codeServer.precompile=false -Dgwt.style=PRETTY -Dgwt.draftCompile=true"

# gwt
alias mgwtcl="mvnrun gwt:clean -o $@"
alias mgwtrn="mvnrun gwt:run -DskipTests -o -Pdevmode $noCheckstyle $gwtOpts -Dgwt.noserver=true -Dgwt.superDevMode=false  $@"
alias mgwtdg="mvnrun gwt:debug -DskipTests -o -Psdm $noCheckstyle $gwtOpts -Dgwt.noserver=true -Dgwt.superDevMode=false -Dgwt.debugPort=8957 $@"
alias mgwtcs="mvnrun gwt:run-codeserver -o $noCheckstyle $gwtOpts $@"

# jetty
alias mdgopts="export MAVEN_OPTS='-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n'"
alias mjetty="mvnrun jetty:run -o -Pjetty,hotswap -Djetty.port=8080 -DskipTests $noCheckstyle"
#alias mjetty="mvnrun jetty:run-forked -o -Photswap -Djetty.port=8081 -Dcheckstyle.skip=true"

function mtest() { mvnrun test -o -DforkCount=0 -DuseIncrementalCompilation=false -Dtest=$1 $noCheckstyle -DfailIfNoTests=false -e $2; }
function mdtest() { mvnDebug test -DforkCount=0 -DuseIncrementalCompilation=false -Dtest=$1 $noCheckstyle -DfailIfNoTests=false -Dmaven.surefire.debug="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000 -Xnoagent -Djava.compiler=NONE" -e $2; }
function mtl() { mvnrun test -o -Dtest=$1 $noCheckstyle -rf :$2 -Pdev -DfailIfNoTests=false -Pdbstage; }
alias mexec="mvn exec:java" # -Dexec.mainClass="com.example.Main" -Dexec.args="arg0 arg1"
# END MAVEN

# GIT
alias g="git"
alias gg="git gui &"
alias gk="gitk &"
alias gcib="git br | xargs -I branch  git ci -m branch"
alias gdbi="(git f master || git p) && git co master && git branch --merged | decolorify | sed 's/^\(\s\|\*\)*//' | grep -v 'master' | xargs -I vranch git branch -d vranch"
alias gdbd="(git f development || git p) && git co development && git branch --merged | decolorify | sed 's/^\(\s\|\*\)*//' | grep -v 'master\|development' | xargs -I vranch git branch -d vranch"
alias gdbm="(git f main || git p) && git co main && git branch --merged | decolorify | sed 's/^\(\s\|\*\)*//' | grep -v 'main' | xargs -I vranch git branch -d vranch"
gdba() {
    target=${1:-main}
    git fetch origin "$target" 2>/dev/null
    git checkout "$target" || return 1
    protect='^(master|develop|dev|development|main)$'
    git branch --merged "$target" | awk '{sub(/^[*+ ]+/,"");
    print}' | grep -Ev "$protect" | while read -r b; do
      [ -n "$b" ] && echo "> Deleting $b" && git branch -D "$b"
    done
    git branch --no-merged "$target" | awk '{sub(/^[*+ ]+/,"");
    print}' | grep -Ev "$protect" | while read -r b; do
      [ -z "$b" ] && continue
      if ! git cherry "$target" "$b" | grep -q '^+'; then
        echo "> Deleting squash-merged $b"
        git branch -D "$b"
      fi
    done
}
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias configk="cd $HOME/.cfg && (gitk &) && cd - > /dev/null"
alias gmr="~/.scripts/git_multiple_rebase.sh"
alias lsg="git ls-tree --name-only HEAD"
function gadd() {
	pattern=$1
	git st | egrep -v -e '->' | egrep $pattern | awk '{print $2}' | xargs git add
}
function gusg() {
	pattern=$1;
	git st | egrep -v -e '->' | egrep $pattern | awk '{print $2}' | xargs git reset HEAD --
}
function gsc() { # git search commits
    limit=$1
    text=$2
    start_at=$3
    file=$4
    i=0
    if [[ -z $file ]]; then
        file="."
    fi
    for commit in $(git log --oneline -n $limit -- $file | decolorify | awk '{print $1}');
    do
        if [[ $((i % 1000)) -eq 0 ]]; then
            echo "Checking commit HEAD~$i"
        fi
        if [[ ${i} -lt ${start_at} ]]; then
            (( i+=1 ))
            continue
        fi
        diff=`git show $commit -p | grep -e "$text"`;
        if [[ ! -z $diff ]]; then
            echo "Commit: $commit (maybe: HEAD~${i})"
            echo ${diff}
        fi
        (( i+=1 ))
    done
}
alias gsu_cg="git config --global user.email vwjugow@consultoriaglobal.com.ar"
alias gsu_vw="git config --global user.email victorwjugow@gmail.com"
alias gsu_bc="git config --global user.email victor.wjugow@britecore.com"
function gdif() {
    if [ -d .git ]; then
        preview="git diff $@ --color=always -- {-1}"
        execute="enter:execute(git difftool {} < /dev/tty)"
        git diff $@ --name-only | fzf -m --ansi --bind $execute --preview $preview
    else
        echo "It's not a git repository"
    fi;
}
# END GIT

# SERVERS
alias w6="~/Documents/dev/servers/jboss-eap-6.1/bin/standalone.sh"
alias cw6="rm -f ~/Documents/dev/servers/jboss-eap-6.1/standalone/deployments/*war; rm -df ~/Documents/dev/servers/jboss-eap-6.1/standalone/deployments/*war*; rm -f ~/Documents/dev/servers/jboss-eap-6.1/standalone/deployments/*jar; rm -df ~/Documents/dev/servers/jboss-eap-6.1/standalone/deployments/*jar*;"
alias dw6="cp -vf target/*.war ~/Documents/dev/servers/jboss-eap-6.1/standalone/deployments; cp -vf target/*.jar ~/Documents/dev/servers/jboss-eap-6.1/standalone/deployments;"
alias w7="~/Documents/dev/servers/jboss-as-7.1.1/bin/standalone.sh"
alias cw7="rm -f ~/Documents/dev/servers/jboss-eap-7.1.1/standalone/deployments/*war; rm -df ~/Documents/dev/servers/jboss-as-7.1.1/standalone/deployments/*war*; rm -f ~/Documents/dev/servers/jboss-as-7.1.1/standalone/deployments/*jar; rm -df ~/Documents/dev/servers/jboss-as-7.1.1/standalone/deployments/*jar*;"
alias dw7="cp -vf target/*.war ~/Documents/dev/servers/jboss-as-7.1.1/standalone/deployments; cp -vf target/*.jar ~/Documents/dev/servers/jboss-as-7.1.1/standalone/deployments;"
alias w8="~/Documents/dev/servers/wildfly-8.2.1.Final/bin/standalone.sh"
alias cw8="rm ~/Documents/dev/servers/wildfly-8.2.1.Final/standalone/deployments/*war; rm -d ~/Documents/dev/servers/wildfly-8.2.1.Final/standalone/deployments/*war*;"
alias dw8="cp -vf target/*.war ~/Documents/dev/servers/wildfly-8.2.1.Final/standalone/deployments; cp -vf target/*.jar ~/Documents/dev/servers/wildfly-8.2.1.Final/standalone/deployments;"
# END SERVERS

# SQL
alias sqlDevLille="sqlplus64 '$LG_DB_DEV_USER/$LG_DB_DEV_PW@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=ehr-db.dev.int.aws.lillegroup.com)(PORT=2483))(CONNECT_DATA=(SID=ehrdev)))'"
alias gqlDevLille="gqlplus '$LG_DB_DEV_USER/$LG_DB_DEV_PW@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=ehr-db.dev.int.aws.lillegroup.com)(PORT=2483))(CONNECT_DATA=(SID=ehrdev)))'"
alias gqlStgLille="gqlplus '$LG_DB_STG_USER/$LG_DB_STG_PW@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=ehr-db.stage.int.aws.lillegroup.com)(PORT=2483))(CONNECT_DATA=(SID=ehrstg)))'"
alias postgresMagick="psql -h localhost -p 5432  -U magick"
alias postgresDocker="psql -h localhost -p 38036 -U magick"
function fwInfo() { mvn flyway:info -Dflyway.configFile=$1; }
function fwMig() { mvn flyway:migrate -Dflyway.configFile=$1; }
function fwClean() { mvn flyway:repair -Dflyway.configFile=$1; }
#alias postgresRhc="psql -h localhost -p $PORT $DB $USER"
alias bcmysql="mysql -u docker -P 3307 -h localhost --protocol=tcp -p"
# END SQL

## Kubectl
alias k=kubectl
alias ka="kubectl apply -f"
alias ke="kubectl get events --sort-by=.metadata.creationTimestamp"
## END Kubectl

# DOCKER
function uiDockerExec() {
	docker ps | grep docker_ui | awk '{print $1}' | xargs -I id docker exec -i id $*
}
bcdt="docker-compose exec briterules-api coverage run -m pytest" #run python tests in docker container
function bcdc() { # bcdc bankers start
    client=$1
    docker_action=$2
    docker-compose -f clients-${client}.yml -p ${client} ${docker_action}
}
function bcdlc() { # bcdlc bankers
    client=$1
    docker exec -it ${client}_web_1 bash
}
alias dcsp="docker compose stop"
alias dcst="docker compose start"
function drmi() { # drmi bankers
    query=$1
    docker container ls --all | grep ${query} | cut -d " " -f 1 | xargs docker rm -v
    docker image prune
    docker images | grep ${query}  | cut -d " " -f 1 | xargs docker rmi
}
alias dprune="docker system prune -a -f --volumes"
# END DOCKER

# RHC
function rhcsshkeyadd() { rhc sshkey-add $1 $HOME/.ssh/id_rsa.pub; }
alias rhcserveradd="rhc server add $1 $2 -k"
alias rhcdev="rhc server use env-dev"
alias rhcqa1="rhc server use env-qa1"
alias rhcqa2="rhc server use env-qa2"
alias rhcprod="rhc server use prod"
alias rhcit="rhc server use it"
alias rhcvic="rhc setup -l $RHC_USER -p $RHC_PW --server openshift.redhat.com"
# END RHC

### AWS
alias tf=terraform
alias tfa="terraform apply"
alias tfaa="terraform apply -auto-approve"
alias tfp="terraform plan"
alias tfpr="terraform plan -refresh-only"
function aws_get_tasks_arn {
    local AWS_CLUSTER=$1
    local SERVICE_NAME=$2  # ticket-service-sandbox-srv
    aws ecs list-tasks --cluster $AWS_CLUSTER  --service-name $SERVICE_NAME \
        | grep arn | cut -d "/" -f 3 | perl -p -e 's/"//g'
}
function tf_m1_init {
    PLAN_ARGS=$@
    terraform init | grep -E "Could not retrieve the list of available versions\|Error while installing" | grep -E "version\|hashicorp"
    perl -0777 -i -pe 's;provider ".+hashicorp/aws.+\s*version\s*=\s*".+"\s*hashes\s*=\s*\[(\s*".+",\s*)+]\s*};;' .terraform.lock.hcl
    perl -0777 -i -pe 's;provider ".+hashicorp/template.+\s*version\s*=\s*".+"\s*hashes\s*=\s*\[(\s*".+",\s*)+]\s*};;' .terraform.lock.hcl
    m1-terraform-provider-helper install hashicorp/aws -v v4.13.0
    m1-terraform-provider-helper install hashicorp/template -v v2.2.0
    terraform init
    perl -0777 -i -pe 's;provider ".+hashicorp/aws.+\s*version\s*=\s*".+"\s*hashes\s*=\s*\[(\s*".+",\s*)+]\s*};;' .terraform.lock.hcl
    perl -0777 -i -pe 's;provider ".+hashicorp/template.+\s*version\s*=\s*".+"\s*hashes\s*=\s*\[(\s*".+",\s*)+]\s*};;' .terraform.lock.hcl
    terraform plan $PLAN_ARGS
}
function ecsssh {
    AWS_CLUSTER=skydropx-staging-cl
    AWS_CONTAINER=$1
    AWS_TASK=$2
    aws ecs execute-command --cluster $AWS_CLUSTER --task $AWS_TASK --container $AWS_CONTAINER --interactive --command "/bin/sh"
}
function ecsd {
    AWS_CLUSTER=$1
    AWS_SERVICE=$2
    aws ecs update-service --region us-east-1 --cluster ${AWS_CLUSTER} \
        --service ${AWS_SERVICE} --force-new-deployment
}
### END AWS

# LINUX DIAGNOSTICS
alias procesos="ps -ef | grep -v grep | egrep"
alias lsmount="mount | grep \"/media/$USER/\"" #| cut -d\" \" -f1"
alias lsfs="df -Th"
alias lsdir="du -h --max-depth=1"
alias lsmem="free -h"
alias lsusers="getent passwd | cut -d ':' -f 1"
alias lsgroups="cat /etc/group | cut -d ' ' -f 1"
alias sysinfo="inxi -Fazy"
alias pciinfo="mhwd -li -l"

# Arch linux
alias yi='yay -S'              # Install package
alias yis='yay -S --needed'    # Install only if not already installed
alias yid='yay -S --asdeps'    # Install as dependency
alias yu='yay -R'              # Remove package
alias yus='yay -Rs'            # Remove package and unused dependencies
alias yun='yay -Rns'           # Remove package, dependencies, and config files
alias ys='yay -Ss'             # Search packages
alias ysi='yay -Si'            # Show package info
alias yls='yay -Qe'             # List explicitly installed packages
alias ylst='yay -Q'             # List installed packages
alias ylsi='yay -Qi'            # Show info for installed package
alias yup='yay -Syu'            # Update system
alias yc='yay -Sc'             # Clean package cache
alias ycc='yay -Scc'           # Clean all package cache
alias yo='yay -Rns $(yay -Qtdq)' # Remove orphaned packages
alias yupd='yay -Syu --devel'   # Update including AUR devel packages

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'
alias gbc="git br | pbcopy"
function folder_storage {
    folder=$1
    du -h $1 | sort -rh | head -n 10
}
# END CHEATS

# Laburos
## Skydropx
function sxgetenv {
    # sxgetenv ticket-service production prod.env
    aws s3 cp s3://skydropx-devops/env_files/$1/environments/$2/.env $3
}
function sxputenv {
    # sxputenv prod.env ticket-service production
    aws s3 cp $1 s3://skydropx-devops/env_files/$2/environments/$3/.env
}
alias segcp="sem edit secret GCP"
alias seaws="sem edit secret AWS"
alias se="sem edit secret"

### END Laburos
# BriteCore
alias wheredcbc="docker inspect docker-britecore-1 --format='{{range .Mounts}}{{.Source}} -> {{.Destination}}{{\"\\n\"}}{{end}}' | grep -i 'code\/britecore' | cut -d ' ' -f 1"
function bbsiteshell() {
    local site="$1" cluster="test"
    shift
    if [[ "$1" == "--platform" ]]; then cluster="$2"; else [[ -n "$1" ]] && cluster="$1"; fi
    britecore-cli connect --shell --site-name "$site" --cluster "platform-$cluster"
    kubectl config use-context k3d-bc-local
}
function bbsitedb() {
    local site="$1" cluster="test"
    shift
    if [[ "$1" == "--platform" ]]; then cluster="$2"; else [[ -n "$1" ]] && cluster="$1"; fi
    britecore-cli connect --db --site-name "$site" --cluster "platform-$cluster"
    kubectl config use-context k3d-bc-local
}
function kctx() {
    kubectl config get-contexts
}
function bbsiterun() {
  # Usage: bbsiterun <site> [--platform <cluster>] <command...>
  local site="$1" cluster="test"
  shift
  if [[ "$1" == "--platform" ]]; then cluster="$2"; shift 2; fi
  local cmd="$*"
  if [[ -z "$site" || -z "$cmd" ]]; then
    echo "usage: bbsiterun <site> [--platform <cluster>] <command...>" >&2
    return 1
  fi
  local exec_line
  exec_line="$(britecore-cli connect --shell --site-name "$site" --cluster "platform-$cluster" --dry-run 2>/dev/null | grep '^kubectl .* exec ')"
  if [[ -z "$exec_line" ]]; then
    echo "bbsiterun: could not resolve pod for '$site' on platform-$cluster" >&2
    return 1
  fi
  exec_line="${exec_line/ exec -it / exec -i }"   # non-interactive
  exec_line="${exec_line%% -- *}"                  # strip trailing '-- bash'
  eval "$exec_line -- bash -lc 'cd /code/britecore && $cmd'"
}
alias recreate_executor="cd /Users/vwjugow/Documents/code/iws/executor && docker-compose stop && git stash save \"stashed by script\" && docker-compose --build"
alias recreate_executor_for_testing="cd /Users/vwjugow/Documents/code/iws/executor; echo 'unstash the correct changes and run mvn clean package -DskipTests'"

function bctc() { # bctc client project test_regex ##test components
    if [[ -z ${1} ]]; then
        project="quoting-pa:manual_generation"
    else
        project="${1}"
    fi
    test_regex="${2}"
    cd ~/Documents/code/iws
    echo "Running: 'java -jar executor-for-testing.jar -T \\S*${test_regex}\\S* -P ${project};'"
    java -jar executor-for-testing.jar -T \\S\*${test_regex}\\S\* -P ${project};
    cd -
}
function bctc2() { # bctc client project test_regex ##test components
    if [[ -z ${1} ]]; then
        project="quoting-pa:manual_generation"
    else
        project="${1}"
    fi
    test_regex="${2}"
    cd ~/Documents/code/iws/executor
    source ../.venv/bin/activate
    echo "Running: 'mvn exec:java -Dexec.args=\"-T \\S*${test_regex}\\S* -P ${project}\"'"
    mvn exec:java -Dexec.args="-T \\S*${test_regex}\\S* -P ${project}";
    cd -
}

function bcgc() { #project ##generate components
    source ../.venv/bin/activate
    echo "Running: 'python data_generator.py -o ~/Documents/code/iws/drl_projects/ -p ${project}'"
    if [[ -z ${1} ]]; then
        python data_generator.py -o ~/Documents/code/iws/drl_projects/
    else
        python data_generator.py -o ~/Documents/code/iws/drl_projects/ -p ${1}
    fi
}

function bcgatc() { #client project test_regex ##generate and test components
    bcgc $1 && bctc "${1}:manual_generation" $2
}
function export_components() { # url project token <additional argument for importer>"
    URL=$1
    PRJ=$2
    TKN=$3
    EXTRA=$4
    if [[ -z $TKN ]]; then
        echo "Running: python data_importer.py -u $URL -j $PRJ -x -n $EXTRA"
        python data_importer.py -u $URL -j $PRJ -x -n $EXTRA
    else
        echo "Running: python data_importer.py -u $URL -t $TKN -j $PRJ -x -n $EXTRA"
        python data_importer.py -u $URL -t $TKN -j $PRJ -x -n $EXTRA
    fi
}
alias export_cover_quoting='export_components https://api.cover-uat.britecore.com cover-quoting-personalAuto ${TOKEN}'
alias export_amic_quoting='export_components https://api.augusta.britecore.com quoting-pa ${TOKEN}'
alias export_amic_form='export_components https://api.augusta.britecore.com form-inclusion-personal-auto ${TOKEN}'
function replace_components_repo() { # zip_query
    zip_query=$1
    project=`echo $zip_query | perl -p -e 's:.*/([a-zA-Z0-9\-]+)-[0-9]+\\.zip:\\1:g'`
    echo "Do you want to remove folder ./projects/${project}?"
    read delete_projects_folder
    if [[ $delete_projects_folder == "y" ]]; then
        rm -r ./projects/${project};
    fi
    echo "Do you want to delete the zip afterwards? (y/n)"
    read delete_zip
    unzip -qq ${zip_query} -d ./
    if [[ $delete_zip == "y" ]]; then
        rm ${zip_query}
    fi
}

alias replace_cover_quoting="replace_components_repo ~/Downloads/cover-quoting-*"
alias replace_amic_quoting="replace_components_repo ~/Downloads/quoting-pa-*"
alias replace_amic_forms="replace_components_repo ~/Downloads/form-inclusion-personal-auto*"

py_clear_cache="--cache-clear"
function brt() {
    if [[ -z `echo ${VIRTUAL_ENV}` ]]; then
        source .venv/bin/activate
    fi
    coverage run -m pytest -k $1
}
function brtc() {
    if [[ -z ${VIRTUAL_ENV} ]]; then
        source ../.venv/bin/activate
    fi;
    coverage run -m pytest $py_clear_cache -k $1
}
alias ave="source .venv/bin/activate"
function bcflake8() { # bcflake8 [Number of previous commits to compare against]
	if [ -z $1 ]; then
		git diff -U0 HEAD -- '*.py' | decolorify > head_diff
	else
		git diff -U0 HEAD~$1...HEAD -- '*.py' | decolorify > head_diff
	fi
	FLAKE_ERRORS=$( python -m flake8 --config .flake8 --diff < head_diff )
	rm head_diff
	echo $FLAKE_ERRORS
}
function _resolve_test_path() {
  local INPUT=$1
  if [[ "$INPUT" == *"/"* ]]; then
      echo "/code/britecore/${INPUT#./}"
  elif [[ "$INPUT" == *"."* && "$INPUT" != *.py ]]; then
      echo "/code/britecore/${INPUT//./\/}.py"
  else
      local LOCAL_FILE=$(timeout 5 find . -path "./tests/*" -name "${INPUT}.py" -type f -maxdepth 4 2>/dev/null | head -n 1)
      if [[ -z "$LOCAL_FILE" ]]; then
          echo "ERROR: Could not find test file: $INPUT (tried searching for ${INPUT}.py under ./tests/*)" >&2
          return 1
      fi
      echo "/code/britecore/${LOCAL_FILE#./}"
  fi
}
function bct() {
  local TEST_FILE=$(_resolve_test_path "$1")
  [[ "$TEST_FILE" == ERROR* ]] && return 1
  local K_FLAG=""
  if [[ -n "$2" ]]; then
      K_FLAG="-k '$2'"
      shift 2
  else
      shift
  fi
  local CMD="source /code/.venv3/bin/activate && DATABASE_NAME=\$DATABASE_NAME_FOR_TESTS /code/britecore/run.py test $TEST_FILE $K_FLAG --database-name \$DATABASE_NAME_FOR_TESTS $*"
  echo "Running: dce britecore bash -c \"$CMD\""
  dce britecore bash -c "$CMD"
}
function bctests() { # tests/unit_tests/test_lib_policies_utils.py::TestUnderwritingRuleEnforcer:test_name
    test_query=$1
    cd ~/Documents/code/iws/BriteDevEnv
    load_britedevenv
    ./tools/run_unit_tests.sh $test_query
    cd -
}
function bc_rename_rule () {
    tgt_folder=$1
    src_file=$2
    tgt_file=$3
    name=$4
    new_name=$5; mkdir $tgt_folder
    git mv $src_file $tgt_file
    sed -e "s/${name}/${new_name}/g" -i "" $tgt_file
}
function bcurl() {
    echo $1 | perl -pe 's:/britecore/policies/.*\?:/agent/policies/wizard/policy_setup\?:' | sed -E 's/\\//g'| pbcopy && pbpaste | sed -E 's/\\//g'
}
function bc-tunnel {
    BC_DB_PORT=3308
    if ! [ $1 ] || ! [ $2 ]; then
        echo "Please pass BC site name and gh username"
        echo "E.g: bc-tunnel augusta-uat-new big_foot"
    else
        if [ $3 ]; then
            BC_DB_PORT=$3
        fi
        echo "Using local port $BC_DB_PORT"
        GH_USERNAME="$2"
        SERVER_NAME=($(tsh ls | grep "^$1" | cut -d' ' -f1))
        echo "Retrieving credentials..."
        DB_DETAILS=$(tsh ssh "$GH_USERNAME@$SERVER_NAME" /srv/www/britecore/.venv/bin/python /srv/www/britecore/bin/encrypt_britecore_cfg.py --in-file /srv/www/britecore/britecore.cfg --decrypt | grep database -A 8)
        echo "Updating .env"
        BC_DB_NAME=$(echo $DB_DETAILS | perl -lne "print for /^name = (.+)/")
        BC_DB_PASS=$(echo $DB_DETAILS | perl -lne "print for /^pass = (.+)/")
        BC_DB_USER=$(echo $DB_DETAILS | perl -lne "print for /^user = (.+)/")
        echo "BC_DB_NAME=$BC_DB_NAME"
        echo "BC_DB_PASS=$BC_DB_PASS"
        echo "BC_DB_USER=$BC_DB_USER"
        echo "BC_DB_PORT=$BC_DB_PORT"
        echo "Creating tunnel"
        echo ""
        tsh ssh -L "$BC_DB_PORT:$1.cluster-chwjvuzxkgh9.us-east-1.rds.amazonaws.com:3306" "$GH_USERNAME@$SERVER_NAME"
    fi
}
# Refresh CodeArtifact tokens WITHOUT resetting the default registry/index.
# Public npm/PyPI stay the default (no auth for everyday work); CodeArtifact is
# only used for the @britecore/@fortawesome (npm) and private (pip) packages.
_bc_ca_token() {
    aws codeartifact get-authorization-token \
        --domain britecore --domain-owner 313750358190 \
        --region us-east-1 --query authorizationToken --output text
}
bcnpmlg() {
    local token; token=$(_bc_ca_token) || return 1
    npm config set //britecore-313750358190.d.codeartifact.us-east-1.amazonaws.com/npm/npm-all/:_authToken "$token"
    echo "CodeArtifact npm token refreshed (default registry stays public npm)."
}
bcpiplg() {
    local token; token=$(_bc_ca_token) || return 1
    mkdir -p ~/.config/pip
    cat > ~/.config/pip/pip.conf <<EOF
[global]
index-url = https://pypi.org/simple/
extra-index-url = https://aws:${token}@britecore-313750358190.d.codeartifact.us-east-1.amazonaws.com/pypi/pypi-all/simple/
EOF
    echo "CodeArtifact pip token refreshed (default index stays public PyPI)."
}
bclogin() {
    aws sso login --profile bcpro
    bcpiplg
    bcnpmlg
}
bcupg() {
    gh auth token | xargs -I{} uv tool install --python=3.14 \
    --compile-bytecode 'git+https://x-access-token:{}@github.com/IntuitiveWebSolutions/britecore-cli.git@v2.1.5'
}
bbs3() {
    local carrier="$1"
    local ptid="$2"
    local bbsite="$3"
    local prefix="${ptid:0:2}"
    local dryrun=""
    if [[ "$4" == "-d" ]]; then
      dryrun="--dryrun"
    fi
    local cmd="aws s3 cp \
      s3://britecorepro-assets/${carrier}/uploads/policy_types/${prefix}/${ptid} \
      s3://britecorepro-test/${bbsite}/uploads/policy_types/${prefix}/${ptid} \
      --recursive $dryrun"
    local output
    output=$(eval "$cmd" 2>&1)
    local rc=$?
    if [[ $rc -ne 0 && "$output" == *"Token has expired and refresh failed"* ]]; then
      echo "SSO token expired, re-authenticating..."
      aws sso login --profile bcpro
      output=$(eval "$cmd" 2>&1)
      rc=$?
    fi
    echo "$output"
    return $rc
}
# End BriteCore
# OTHERS
alias lzg="lazygit"
alias lzd="lazydocker"
function epub2mobi() { ebook-convert $1 $(basename $1 ".epub")".mobi"; }
alias xc="xclip -selection clipboard"
alias restartNetwork="sudo service network-manager restart"
alias remminaClean="rm ~/.freerdp/known_hosts"
function ftext() { grep -RnIH '.' -e $2 --include=\*${1} --exclude-dir=$3; }
function ftexti() { grep -RnIHi '.' -e $2 --include=$1 --exclude-dir=$3; }
alias fname="find . | grep $1"
# alias unzip="gzip -d"
alias firefox="MOZ_ACCELERATED=1 MOZ_GLX_IGNORE_BLACKLIST=1 firefox"
alias showAlias="cat ~/.scripts/aliases.sh | grep -C2 -e"
alias p="play"
alias v="xviewer"
alias pdf="xreader"
alias pdf2="qpdfview"
alias ltxc="pdflatex" # file.tex
alias compressFolder="tar -zcvf" #tar.gz folder
alias uncompressFolder="tar -zxvf" #tar.gz -C folder
alias pwdp="pwd -P"
alias mac="Documents/bin/mat/MemoryAnalyzer -vmargs -Xmx4g -XX:-UseGCOverheadLimit"
alias decolorify="sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g'"
function soundPortToggle() {
	if [[ -z `pacmd list-sinks | grep 'active port' | grep -v 'hdmi' | grep 'headphones'` ]]; then
		pacmd set-sink-port 1 analog-output-headphones
	else
		pacmd set-sink-port 1 analog-output-lineout
	fi
}
function create_bootable_disk() { sudo dd bs=4M if=$1 of=$2; } # create_bootable_disk disk.iso /dev/sdd # check with lsblk
function decrypt() { OUTPUT=$2; INPUT=$1; gpg -d -o $OUTPUT $INPUT; }
alias overgrive="python2 /opt/thefanclub/overgrive/overgrive"
alias lastSaturday="cd ~/.scripts/ && java LastSaturday"
alias letztenSonntag="cd ~/.scripts/ && java LastSunday"
function laMaquina() {
    day=`lastSaturday`
    firefox -new-window https://radiocut.fm/radiostation/delta/listen/$day/10/30/00/
}
function spl_chk_es() {
    file_to_check=$1
    ignore_dict=$2
	if [[ -z $ignore_dict ]]; then
        ignore_dict=".aspell.es.pws"
    fi
    cat $file_to_check | aspell --lang=es --mode=tex --ignore-case --home-dir=. --personal=$ignore_dict list | sort -u
}
alias refresh_ipv6_settings="sudo sysctl -p"
alias mtsa_nologs_bg="(java -jar ~/Documents/dev/projects/kuvic/mtsa/maven-root/mtsa/target/mtsa-1.0-SNAPSHOT.jar > /dev/null 2>&1) &"
alias mtsa_nologs_fg="java -jar ~/Documents/dev/projects/kuvic/mtsa/maven-root/mtsa/target/mtsa-1.0-SNAPSHOT.jar > /dev/null 2>&1"
alias mtsa="java -jar ~/Documents/dev/projects/kuvic/mtsa/maven-root/mtsa/target/mtsa-1.0-SNAPSHOT.jar 2>&1"
alias fix_spotify_key="curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -"
alias clean_docker="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc -e REMOVE_VOLUMES=1 spotify/docker-gc"
    # NVM
function load_nvm() {
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}
    # Ruby
function load_rbenv() {
    eval "$(rbenv init - zsh)"
    export PATH="/opt/homebrew/opt/imagemagick@6/bin:$PATH"
    export LDFLAGS="-L/opt/homebrew/opt/libffi/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/libffi/include"
    export PKG_CONFIG_PATH="/opt/homebrew/opt/libffi/lib/pkgconfig"
}
alias lines_to_list="sed -e 's/\\n/ /g'"
alias fix_external_kb="setxkbmap -layout us,es,ru -variant ,ast,phonetic_YAZHERTY -option 'grp:alt_shift_toggle'"
alias sleft="xrandr --output VGA-1 --auto --left-of eDP-1"
alias sright="xrandr --output VGA-1 --auto --right-of eDP-1"
alias ssame="xrandr --output VGA-1 --auto --same-as eDP-1"
alias audio="pavucontrol"
alias cld="claude --dangerously-skip-permissions"
alias cdx="codex --full-auto"
# END OTHERS
