### Convert unix time to date
    date -d @1232144092
    date -d "Apr 25, 2011 12:12:12" +%s

# Git
    git fetch -p
    git submodule add <git@github ...> snipmate-snippets/snippets/

### Using sed and awk to filter command line output
    ll | sed -n "1,10p" | awk '{print $0}'

### ack file
    ack -Q --smart-case --js --ignore-file=match:/packed.*\.js/ --ignore-file=is:Code/tag --ignore-dir=build --ignore-dir=Code/JSON --ignore-dir=Tools "test"

### Copy using rsync
    rsync -lav -P source dest

### Map localhost port to some server port
    ssh -L localhost:3306:192.168.56.201:3306 ubuntu@xx.xx.xx.xx -i ~/.ssh/id_rsa

### Map localhost port to some other port
    ssh -L localhost:3306:192.168.56.201:3306 -N 127.0.0.1

### Calculation
    echo "ibase=10;obase=16; 255"|bc -l
    echo "5/3" | bc -l

### Using xargs and find and awk
    find . -name "*.bak" -print0 | awk '{print $0}' | xargs -0 -I {} mv {} ~/old.files
