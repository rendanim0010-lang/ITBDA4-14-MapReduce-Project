import java.io.IOException;

import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.JobContext;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;

public class WholeFileInputFormat
        extends FileInputFormat<NullWritable, BytesWritable> {

    /*
     * Each file must remain as one input split so that one Mapper
     * receives the complete document.
     */
    @Override
    protected boolean isSplitable(
            JobContext context,
            org.apache.hadoop.fs.Path filename) {

        return false;
    }

    /*
     * Create the RecordReader that will read the entire document.
     */
    @Override
    public RecordReader<NullWritable, BytesWritable> createRecordReader(
            InputSplit split,
            TaskAttemptContext context)
            throws IOException, InterruptedException {

        return new WholeFileRecordReader();
    }
}
