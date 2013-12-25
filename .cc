# Copy using rsync
rsync -l -P source dest

# Map localhost port to some server port
ssh -L localhost:3306:192.168.56.201:3306 ubuntu@xx.xx.xx.xx -i ~/.ssh/id_rsa

# Map localhost port to some other port
ssh -L localhost:3306:192.168.56.201:3306 -N 127.0.0.1

# Calculation
echo "ibase=10;obase=16; 255"|bc -l
echo "5/3" | bc -l

# Using xargs and find and awk
find . -name "*.bak" -print0 | awk '{print $0}' | xargs -0 -I {} mv {} ~/old.files
