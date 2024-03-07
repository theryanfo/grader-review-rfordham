
rm -rf student-submission
rm -rf grading-area

mkdir grading-area

#1. Clone Submission

git clone $1 student-submission 2> clone-output.txt
echo 'Finished cloning'

# 2/3. Check correct file submission & cp file into grading-area/

if [ -f student-submission/ListExamples.java ]
then
    cp student-submission/ListExamples.java grading-area/
    cp TestListExamples.java grading-area/
else 
    echo "Missing ListExamples.java, did you forget the file or misname it?"
    exit 1
fi

# 4. Compile tests and student's code from grading-area/

cd grading-area/
CPATH=".;../lib/hamcrest-core-1.3.jar;../lib/junit-4.13.2.jar"
javac -cp $CPATH *.java

if [ $? -ne 0 ]
then 
    echo "Program failed to compile, see compile error above"
    exit 1
fi

echo "Compile successful"

# 5. Run the tests and report the grade

java -cp $CPATH org.junit.runner.JUnitCore TestListExamples > junit-output.txt

testline=$(cat junit-output.txt | tail -n 2 | head -n 1)
echo "$testline"

# IF ALL TESTS PASS
if [[ $(grep -o "OK" junit-output.txt) == "OK" ]]
then
    tests=$(echo "$testline" | awk -F'[(]' '{print $2}')
    echo "$tests"
    # passed=$(cat "$testline" | awk -F'[(]' '{print $2}')
    echo "Perfect!"
    # echo "$passed"
fi

# IF NOT ALL TESTS PASS
if [[ $(grep -o "Failures:" junit-output.txt) == "Failures:" ]]
then
    failures=$(echo "$testline" | grep -oP 'Failures: \K\d+')
    tests_run=$(echo "$output" | grep -oP 'Tests run: \K\d+')

    echo "Number of Failures: $failures"
    echo "Number of Tests run: $tests_run"
fi
