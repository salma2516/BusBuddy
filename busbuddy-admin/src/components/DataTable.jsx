function DataTable({

  title,

  columns,

  data

}) {

  return (

    <div className="table-container">

      <h2>

        {title}

      </h2>

      <table>

        <thead>

          <tr>

            {columns.map(

              (column, index) => (

                <th key={index}>

                  {column}

                </th>

              )
            )}

          </tr>

        </thead>

        <tbody>

          {data.map(

            (row, index) => (

              <tr key={index}>

                {columns.map(

                  (column, idx) => (

                    <td key={idx}>

                      {row[column]}
                    </td>

                  )
                )}

              </tr>

            )
          )}

        </tbody>

      </table>

    </div>

  );
}

export default DataTable;