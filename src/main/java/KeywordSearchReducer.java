import java.io.IOException;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class KeywordSearchReducer
        extends Reducer<Text, Text, Text, Text> {

    @Override
    protected void reduce(
            Text key,
            Iterable<Text> values,
            Context context)
            throws IOException, InterruptedException {

        /*
         * key    = document name
         * values = all row/column locations found in that document
         */
        for (Text location : values) {

            context.write(
                    key,
                    new Text(location.toString())
            );
        }
    }
}