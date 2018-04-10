# Country codes

The valid country codes are the ones defined by the [ISO 3166-1 alpha-3]
specification.

The following list can be downloaded as a pipe (`|`) separated values file from
[here](/resources/country_codes.csv).

<table id='country-codes-table'></table>
<script src = '/resources/js/papaparse.min.js'></script>
<script>
Papa.parse('/resources/country_codes.csv', {
  header: true,
  delimiter: '|',
  download: true,
  complete: function (results) {
    table_html = '<tr>';
    var fields = results.meta.fields;
    fields.forEach(function(field){
      table_html += '<th>' + field.toUpperCase() + '</th>';
    });
    table_html += '</tr>';
    results.data.forEach(function(country){
      table_html += '<tr>';
      fields.forEach(function(field){
        table_html += '<td>' + country[field]  + '</td>';
      });
      table_html += '</tr>';
    });
    document.getElementById('country-codes-table').innerHTML = table_html;
  }
});
</script>

[ISO 3166-1 alpha-3]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3
