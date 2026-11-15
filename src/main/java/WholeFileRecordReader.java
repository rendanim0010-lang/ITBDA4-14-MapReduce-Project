import java.io.IOException;

import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.IOUtils;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;

public class WholeFileRecordReader
        extends RecordReader<NullWritable, BytesWritable> {

    private FileSplit fileSplit;
    private boolean processed = false;

    private final NullWritable key = NullWritable.get();
    private final BytesWritable value = new BytesWritable();

    @Override
    public void initialize(
            InputSplit split,
            TaskAttemptContext context)
            throws IOException {

        this.fileSplit = (FileSplit) split;
    }

    @Override
    public boolean nextKeyValue() throws IOException {

        // Only read the document once.
        if (processed) {
            return false;
        }

        byte[] contents =
                new byte[(int) fileSplit.getLength()];

        Path file = fileSplit.getPath();

        FileSystem fileSystem =
                file.getFileSystem(
                        fileSplit.getPath()
                                .getFileSystem(
                                        new org.apache.hadoop.conf.Configuration())
                                .getConf()
                );

        FSDataInputStream inputStream = null;

        try {

            inputStream = fileSystem.open(file);

            IOUtils.readFully(
                    inputStream,
                    contents,
                    0,
                    contents.length
            );

            value.set(
                    contents,
                    0,
                    contents.length
            );

        } finally {

            IOUtils.closeStream(inputStream);
        }

        processed = true;

        return true;
    }

    @Override
    public NullWritable getCurrentKey() {
        return key;
    }

    @Override
    public BytesWritable getCurrentValue() {
        return value;
    }

    @Override
    public float getProgress() {
        return processed ? 1.0f : 0.0f;
    }

    @Override
    public void close() {
        // Stream is closed immediately after the file is read.
    }
}
