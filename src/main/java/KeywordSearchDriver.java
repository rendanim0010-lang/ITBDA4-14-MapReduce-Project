import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class KeywordSearchDriver {

    public static void main(String[] args) throws Exception {

        /*
         * Expected command-line arguments:
         * args[0] = input directory
         * args[1] = output directory
         * args[2] = keyword
         */
        if (args.length != 3) {
            System.err.println(
                "Usage: KeywordSearchDriver <input> <output> <keyword>"
            );
            System.exit(1);
        }

        // Read the command-line arguments.
        String inputPath = args[0];
        String outputPath = args[1];
        String keyword = args[2];

        // Create the Hadoop configuration.
        Configuration configuration = new Configuration();

        // Execute MapReduce locally within the Codespace.
        configuration.set("mapreduce.framework.name", "local");
        configuration.set("fs.defaultFS", "file:///");

        /*
         * Store the dynamically supplied keyword.
         * KeywordSearchMapper retrieves this value using
         * the same configuration property.
         */
        configuration.set("search.keyword", keyword);

        // Create and name the MapReduce job.
        Job job = Job.getInstance(
                configuration,
                "Keyword Search MapReduce"
        );

        // Specify the main application class.
        job.setJarByClass(KeywordSearchDriver.class);

        // Configure the Mapper and Reducer.
        job.setMapperClass(KeywordSearchMapper.class);
        job.setReducerClass(KeywordSearchReducer.class);

        /*
         * Use WholeFileInputFormat so that an entire
         * news document is sent to one Mapper.
         */
        job.setInputFormatClass(WholeFileInputFormat.class);

        // Configure Mapper output types.
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(Text.class);

        // Configure final Reducer output types.
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);

        // Configure the input directory.
        FileInputFormat.addInputPath(
                job,
                new Path(inputPath)
        );

        // Configure the output directory.
        FileOutputFormat.setOutputPath(
                job,
                new Path(outputPath)
        );

        // Run the MapReduce job and wait for completion.
        boolean success = job.waitForCompletion(true);

        // Exit with 0 for success and 1 for failure.
        System.exit(success ? 0 : 1);
    }
}