<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.22.4-Białowieża" styleCategories="Fields|Forms">
  <fieldConfiguration>
    <field name="co_id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="gmlid" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="name" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="description" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="creation_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="last_modification_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="updating_person" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="timevaluesprop_acquisitionme" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" name="AllowMulti" value="false"/>
            <Option type="bool" name="AllowNull" value="true"/>
            <Option type="QString" name="FilterExpression" value="data_model = 'Energy ADE 1.0' AND name = 'AcquisitionMethodValue'"/>
            <Option type="QString" name="Key" value="value"/>
            <Option type="QString" name="Layer" value="_v_enumeration_value_"/>
            <Option type="int" name="NofColumns" value="1"/>
            <Option type="bool" name="OrderByValue" value="true"/>
            <Option type="bool" name="UseCompleter" value="false"/>
            <Option type="QString" name="Value" value="description"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="timevaluesprop_interpolation" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" name="AllowMulti" value="false"/>
            <Option type="bool" name="AllowNull" value="true"/>
            <Option type="QString" name="FilterExpression" value="data_model = 'Energy ADE 1.0' AND name = 'InterpolationTypeValue'"/>
            <Option type="QString" name="Key" value="value"/>
            <Option type="QString" name="Layer" value="_v_enumeration_value_"/>
            <Option type="int" name="NofColumns" value="1"/>
            <Option type="bool" name="OrderByValue" value="true"/>
            <Option type="bool" name="UseCompleter" value="false"/>
            <Option type="QString" name="Value" value="description"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="timevaluesprop_qualitydescri" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="timevaluesprop_thematicdescr" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="timevaluespropertiest_source" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="decimalsymbol" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="fieldseparator" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="file_" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="numerofheaderlines" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="recordseparator" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="timeinterval" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="timeinterval_unit" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="timeperiodprop_beginposition" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="timeperiodproper_endposition" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="uom" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="valuescolumnnumber" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="timevaluesprop_acquisitionme" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" name="AllowMulti" value="false"/>
            <Option type="bool" name="AllowNull" value="true"/>
            <Option type="QString" name="FilterExpression" value="data_model = 'Energy ADE 1.0' AND name = 'AcquisitionMethodValue'"/>
            <Option type="QString" name="Key" value="value"/>
            <Option type="QString" name="Layer" value="_v_enumeration_value_"/>
            <Option type="int" name="NofColumns" value="1"/>
            <Option type="bool" name="OrderByValue" value="true"/>
            <Option type="bool" name="UseCompleter" value="false"/>
            <Option type="QString" name="Value" value="description"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="timevaluesprop_interpolation" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" name="AllowMulti" value="false"/>
            <Option type="bool" name="AllowNull" value="true"/>
            <Option type="QString" name="FilterExpression" value="data_model = 'Energy ADE 1.0' AND name = 'InterpolationTypeValue'"/>
            <Option type="QString" name="Key" value="value"/>
            <Option type="QString" name="Layer" value="_v_enumeration_value_"/>
            <Option type="int" name="NofColumns" value="1"/>
            <Option type="bool" name="OrderByValue" value="true"/>
            <Option type="bool" name="UseCompleter" value="false"/>
            <Option type="QString" name="Value" value="description"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="timevaluesprop_qualitydescri" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="timevaluesprop_thematicdescr" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="timevaluespropertiest_source" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias index="0" field="co_id" name="Database ID"/>
    <alias index="1" field="id" name="Database ID"/>
    <alias index="2" field="timeinterval" name="Time Interval"/>
    <alias index="3" field="gmlid" name="GML ID"/>
    <alias index="4" field="name" name="Name"/>
    <alias index="5" field="description" name="Description"/>
    <alias index="6" field="creation_date" name="Creation Date"/>
    <alias index="7" field="last_modification_date" name="Last Modification Date"/>
    <alias index="8" field="updating_person" name="Updating Person"/>
    <alias index="11" field="timeinterval_unit" name="Time Interval Unit"/>
    <alias index="12" field="timeperiodprop_beginposition" name="Time Period Begins"/>
    <alias index="13" field="timeperiodproper_endposition" name="Time Period Ends"/>
    <alias index="16" field="timevaluesprop_acquisitionme" name="Acquisition Method"/>
    <alias index="17" field="timevaluesprop_interpolation" name="InterpolationType"/>
    <alias index="18" field="timevaluesprop_qualitydescri" name="Quality Description"/>
    <alias index="19" field="timevaluesprop_thematicdescr" name="Thematic Description"/>
    <alias index="6" field="decimalsymbol" name="Decimal Symbol"/>
    <alias index="7" field="fieldseparator" name="Field Separator"/>
    <alias index="8" field="file_" name="File"/>
    <alias index="11" field="numberofheaderlines" name="Number of Header Lines"/>
    <alias index="12" field="recordseparator" name="Record Separator"/>
    <alias index="2" field="timeinterval" name="Time Interval"/>
    <alias index="15" field="uom" name="UoM"/>
    <alias index="14" field="valuescolumnnumber" name="Values Column Number"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint notnull_strength="1" field="co_id" unique_strength="1" constraints="3" exp_strength="0"/>
    <constraint notnull_strength="1" field="id" unique_strength="1" constraints="3" exp_strength="0"/>
    <constraint notnull_strength="0" field="valuescolumnnumber" unique_strength="0" constraints="4" exp_strength="1"/>
    <constraint notnull_strength="0" field="uom" unique_strength="4" constraints="0" exp_strength="1"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="Both values must either be NULL or NOT NULL" field="valuescolumnnumber" exp="(&quot;valuescolumnnumber&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;valuescolumnnumber&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;uom&quot; IS NULL)"/>
    <constraint desc="Both values must either be NULL or NOT NULL" field="values_uom" exp="(&quot;valuescolumnnumber&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;valuescolumnnumber&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;uom&quot; IS NULL)"/>
  </constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <attributeEditorForm>
    <attributeEditorContainer name="Main Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="0" columnCount="2">
      <attributeEditorField index="0" name="co_id" showLabel="1"/>
      <attributeEditorField index="1" name="id" showLabel="1"/>
      <attributeEditorField index="2" name="gmlid" showLabel="1"/>
      <attributeEditorField index="3" name="name" showLabel="1"/>
      <attributeEditorField index="4" name="description" showLabel="1"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Database Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="0" columnCount="2">
      <attributeEditorField index="5" name="creation_date" showLabel="1"/>
      <attributeEditorField index="6" name="last_modification_date" showLabel="1"/>
      <attributeEditorField index="7" name="updating_person" showLabel="1"/>
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <attributeEditorContainer name="TimeSeries Attributes" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="0" columnCount="2">
      <attributeEditorField index="8" name="timevaluesprop_acquisitionme" showLabel="1"/>
      <attributeEditorField index="9" name="timevaluesprop_interpolation" showLabel="1"/>
      <attributeEditorField index="10" name="timevaluesprop_qualitydescri" showLabel="1"/>
      <attributeEditorField index="11" name="timevaluesprop_thematicdescr" showLabel="1"/>
      <attributeEditorField index="12" name="timevaluespropertiest_source" showLabel="1"/>
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <attributeEditorContainer name="RegularTimeSeries Attributes" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="0" columnCount="2">
      <attributeEditorField index="6" name="decimalsymbol" showLabel="1" />
      <attributeEditorField index="7" name="fieldseparator" showLabel="1" />
      <attributeEditorField index="8" name="file_" showLabel="1" />
      <attributeEditorField index="11" name="numberofheaderlines" showLabel="1" />
      <attributeEditorField index="12" name="recordseparator" showLabel="1" />
      <attributeEditorField index="2" name="timeinterval" showLabel="1"/>
      <attributeEditorField index="15" name="uom" showLabel="1" />
      <attributeEditorField index="14" name="valuescolumnnumber" showLabel="1" />
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field name="co_id" editable="0"/>
    <field name="creation_date" editable="0"/>
    <field name="gmlid" editable="0"/>
    <field name="id" editable="0"/>
    <field name="last_modification_date" editable="0"/>
    <field name="updating_person" editable="0"/>
  </editable>
  <labelOnTop>
  </labelOnTop>
  <reuseLastValue>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>4</layerGeometryType>
</qgis>
