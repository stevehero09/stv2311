({
    getFormattedDate : function(joinDate) {
        if  ( joinDate == undefined ) {
            return '';
        } else {
            let d = new Date(joinDate),
            mos = ['01','02','03','04','05','06','07','08','09','10','11','12'];
        
            return `${d.getDate()}/${mos[d.getMonth()]}/${d.getFullYear()}`;
        }
    },

    //format date time ticket #APSFSP-57
    getFormattedDateTime : function( dateTime ){

        if  ( dateTime == undefined ) {
            return '';
        } else {
            let d = new Date( dateTime ),
            mos = ['01','02','03','04','05','06','07','08','09','10','11','12'];

            var hours = d.getHours();
            var minutes = d.getMinutes();
            var seconds = d.getSeconds();
            var ampm = hours >= 12 ? 'PM' : 'AM';
            hours = hours % 12;
            hours = hours ? hours : 12; // the hour '0' should be '12'
            var strTime = hours + ':' + minutes + '    ' + ampm;
            return `${d.getDate()}/${mos[d.getMonth()]}/${d.getFullYear()} `+strTime;
        }

    }
})