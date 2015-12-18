### ctags

    ctags --languages=C,C++ --c-kinds=+px --c++-kinds=+px --extra=+fq -R .
    :set tags+=/usr/local/include/tags
    :set tags+=/usr/include/tags
    :set tags+=/System/Library/Frameworks/OpenGL.framework/Versions/A/Headers/tags

### Rsync showing progress
    export SOURCE=<source> DEST=<dest> && export SC=$(find "$SOURCE" | wc -l) rsy&& rsync -vrltd  --stats --human-readable "$SOURCE" "$DEST" | pv -lep -s $SC > /dev/null

### Generate random hash string
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1

### Get size of files and folder
    ls -A | awk '{system("du -sm \""$0"\"")}'| sort -nr | head

### VIM
    :%!tidy -qicbn -asxhtml - Tidy up the whole file HTML

### Copy with rsync and progress
    rsync -l -P source dest

### Convert unix time to date

    date -d @1232144092
    date --set "25 July 2014 15:00:00"
    date -d "17 June 2015 15:00:00" +%s

    date +%s

# Git
    git fetch -p
    git submodule add <git@github ...> snipmate-snippets/snippets/

    git log | cat -s
    git show-ref --tags
    git branch --contains d590f2

    # revert a merge
    git revert -m 1 [sha]

    adb logcat /wgshared/v8helper.h:V *:S

### Using sed and awk to filter command line output
    ll | sed -n "1,10p" | awk '{print $0}'

### ack ag file
    ack -Q --smart-case --ignore-file=match:/packed.*\.js/ --ignore-file=is:Code/tag --ignore-dir=build --ignore-dir=Code/JSON --ignore-dir=Tools --js "test"
    ag -Q --smart-case --ignore=packed.*\.js/ --ignore=Code/tag --ignore-dir=build --ignore-dir=Code/JSON --ignore-dir=Tools --js "test"

### Copy using rsync
    rsync -lav -P source dest

### Map localhost port to some server port
    ssh -L localhost:3306:192.168.56.201:3306 ubuntu@xx.xx.xx.xx -i ~/.ssh/id_rsa

### Map localhost port to some other port
    ssh -L localhost:3306:192.168.56.201:3306 -N 127.0.0.1

### Calculation
    echo "ibase=10;obase=16; 255"|bc -l
    echo "5/3" | bc -l

### Grep excluding files

    grep -ircl --exclude=*.{png,jpg} "foo=" *
    grep -Ir --exclude="*\.svn*" "pattern" *

### Using xargs and find and awk
    find . -name "*.bak" -print0 | awk '{print $0}' | xargs -0 -I {} mv {} ~/old.files

### Bash oneline for
    for i in {1..5}; do echo $i; done
