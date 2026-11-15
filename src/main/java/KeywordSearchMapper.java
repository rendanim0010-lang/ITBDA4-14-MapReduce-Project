import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Locale;

import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;

public class KeywordSearchMapper
        extends Mapper<NullWritable, BytesWritable, Text, Text> {

    private String keyword;

    @Override
    protected void setup(Context context) throws IOException {

        // Retrieve the keyword dynamically from the job configuration.
        keyword = context.getConfiguration().get("search.keyword");

        if (keyword == null || keyword.trim().isEmpty()) {
            throw new IOException(
                    "A search keyword must be supplied when the job is run."
            );
        }

        // Normalise the keyword for a case-insensitive search.
        keyword = keyword.trim().toLowerCase(Locale.ROOT);
    }

    @Override
    protected void map(
            NullWritable key,
            BytesWritable value,
            Context context
    ) throws IOException, InterruptedException {

        // Identify the document currently being processed.
        FileSplit fileSplit = (FileSplit) context.getInputSplit();
        String fileName = fileSplit.getPath().getName();

        // Convert the document bytes into text.
        String document = new String(
                value.getBytes(),
                0,
                value.getLength(),
                StandardCharsets.UTF_8
        );

        /*
         * Split the document into rows.
         * The -1 argument preserves empty rows.
         */
        String[] rows = document.split("\\R", -1);

        for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {

            String originalRow = rows[rowIndex];
            String searchableRow =
                    originalRow.toLowerCase(Locale.ROOT);

            int searchFrom = 0;

            // Find every occurrence of the keyword in the current row.
            while (searchFrom
                    <= searchableRow.length() - keyword.length()) {

                int matchIndex =
                        searchableRow.indexOf(keyword, searchFrom);

                if (matchIndex == -1) {
                    break;
                }

                // Convert Java's zero-based positions to 1-based positions.
                int rowNumber = rowIndex + 1;
                int columnNumber = matchIndex + 1;

                String location =
                        "Row=" + rowNumber
                        + ", Column=" + columnNumber;

                /*
                 * Mapper output:
                 * Key   = document name
                 * Value = keyword location
                 */
                context.write(
                        new Text(fileName),
                        new Text(location)
                );

                /*
                 * Move one character forward.
                 * This also detects overlapping matches.
                 */
                searchFrom = matchIndex + 1;
            }
        }
    }
}