#!/usr/bin/env bash

# Load logging
source log4bash.sh

SCRIPT_DIR="$@"

INPUT_DIR=${INPUT_DIR:-"/input"}
ABC_DIR=${ABC_DIR:-"${INPUT_DIR}/abc"}
ACTIONS_FILE=${ACTIONS_FILE:-"actions.json"}

main() {
  log_info "Starting rules"
  ACTIONS=$(cat "${INPUT_DIR}/${ACTIONS_FILE}")

  # TODO: validate json my_array
  #[[ echo $ACTIONS | jq type ]]

  # For each script
  echo "$ACTIONS" | jq -c '.[]' | while IFS= read -r SCRIPT ; do

    log_info "Working on actions for script: $(echo $SCRIPT | jq -r '.script')"
    FILE=$(echo $SCRIPT | jq -r '.file')
    FILE_PATH=$SCRIPT_DIR/${FILE}
    # TODO Validate file exists

    # Interate through each action
    echo "$SCRIPT" | jq -c '.actions[]' | while IFS= read -r ACTION ; do

      TYPE=$(echo $ACTION | jq -r '.type')
      case $TYPE in

        replace)
          I=$(echo $ACTION | jq -r '.identifier')
          V=$(echo $ACTION | jq -r '.value')
          log_info "Running replace"
          replace "$I" "$V" "$FILE_PATH"
          ;;

        replaceline)
          I=$(echo $ACTION | jq -r '.identifier')
          OF=$(echo $ACTION | jq -r '.offset')
          V=$(echo $ACTION | jq -r '.value')
          ILN=$(find_line "$I" "$FILE_PATH")
          VLN=$(($ILN + $OF))
          log_info "Running replaceline"
          replaceline "$VLN" "$V" "$FILE_PATH"
          ;;

        inject)
          I=$(echo $ACTION | jq -r '.identifier')
          V=$(echo $ACTION | jq -r '.value')
          OF=$(echo $ACTION | jq -r '.offset')
          ILN=$(find_line "$I" "$FILE_PATH")
          VLN=$(($ILN + $OF))
          log_info "Running inject"
          inject "$V" "$VLN" "$FILE_PATH"
          ;;

        insert)
          I=$(echo $ACTION | jq -r '.identifier')
          OF=$(echo $ACTION | jq -r '.offset')
          VF=$(echo $ACTION | jq -r '.file')
          VF="${ABC_DIR}/${VF}"
          ILN=$(find_line "$I" "$FILE_PATH")
          VLN=$(($ILN + $OF))
          log_info "Running insert"
          insert "$VLN" "$VF" "$FILE_PATH"
          ;;

        *)
          log_info "Action type $TYPE is not supported"
          ;;
      esac
    done

  done

}

replace() {
  # Takes $IDENTIFIER $VALUE $FILE_PATH
  I=$1
  V=$2
  FP=$3
  # clean inputs
  I=$(clean_for_regex "$I")
  V=$(clean_for_regex "$V")
  RX='s/(.*)'$I'(.*)/\1'$V'\2/'

  sed -i -r "$RX" "$FP"
}

replaceline() {
  VLN=$1
  V=$2
  FP=$3
  v=$(clean_for_insert "$V")

  sed -i "${VLN}s/.*/$V/" "$FP"
}

inject() {

  V=$1
  VLN=$2
  FP=$3
  V=$(clean_for_insert "$V")

  sed -i "${VLN} a ${V}" "$FP"
}

insert() {

    VLN=$1
    VF=$2
    FP=$3
    sed -i "${VLN} r ${VF}" "$FP"
}

clean_for_regex() {
  I=$1
  # Replace characters
  I=$(echo $I | gsub_literal '\' '\\')
  I=$(echo $I | gsub_literal '"' '\"')
  I=$(echo $I | gsub_literal '/' '\/')
  echo $I
}

clean_for_insert() {
  I=$1
  # Replace characters
  I=$(echo $I | gsub_literal '\' '\\')
  I=$(echo $I | gsub_literal '"' '\"')
  echo $I
}

# usage: find_line REGEX PATH
# finds the line in the file that contains the REGEX
# I believe this will only return the first match
find_line() {
  RX=$1
  FP=$2
  RX=$(clean_for_regex "$RX")
  echo $(grep -En $RX "$FP" | cut -d':' -f1)
}

# usage: gsub_literal STR REP
# replaces all instances of STR with REP. reads from stdin and writes to stdout.
gsub_literal() {
  # STR cannot be empty
  [[ $1 ]] || return

  # string manip needed to escape '\'s, so awk doesn't expand '\n' and such
  awk -v str="${1//\\/\\\\}" -v rep="${2//\\/\\\\}" '
    # get the length of the search string
    BEGIN {
      len = length(str);
    }

    {
      # empty the output string
      out = "";

      # continue looping while the search string is in the line
      while (i = index($0, str)) {
        # append everything up to the search string, and the replacement string
        out = out substr($0, 1, i-1) rep;

        # remove everything up to and including the first instance of the
        # search string from the line
        $0 = substr($0, i + len);
      }

      # append whatever is left
      out = out $0;

      print out;
    }
  '
}

main
