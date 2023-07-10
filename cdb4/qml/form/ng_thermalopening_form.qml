<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.22.4-Białowieża" styleCategories="Fields|Forms">
  <fieldConfiguration>
    <field name="ng_co_id" configurationFlags="None">
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
    <field name="gmlid_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="name" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="name_codespace" configurationFlags="None">
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
    <field name="termination_date" configurationFlags="None">
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
    <field name="relative_to_terrain" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="QString" value="data_model = 'CityGML 2.0' AND name = 'RelativeToTerrainType'" name="FilterExpression"/>
            <Option type="QString" value="value" name="Key"/>
            <Option type="QString" value="_v_enumeration_value_" name="Layer"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="description" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="relative_to_water" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="QString" value="data_model = 'CityGML 2.0' AND name = 'RelativeToWaterType'" name="FilterExpression"/>
            <Option type="QString" value="value" name="Key"/>
            <Option type="QString" value="_v_enumeration_value_" name="Layer"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="true" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="description" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="last_modification_date" configurationFlags="None">
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
    <field name="updating_person" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="reason_for_update" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="lineage" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="area" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="area_uom" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="construction_id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="surfacegeometry_id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="thermalboundary_contains_id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="ng_co_id" index="0" name="Database ID (ng)"/>
    <alias field="id" index="1" name="Database ID"/>
    <alias field="gmlid" index="2" name="GML ID"/>
    <alias field="gmlid_codespace" index="3" name="GML ID Codespace"/>
    <alias field="name" index="4" name="Name"/>
    <alias field="name_codespace" index="5" name="Name Codespace"/>
    <alias field="description" index="6" name="Description"/>
    <alias field="creation_date" index="7" name="Creation Date"/>
    <alias field="termination_date" index="8" name="Termination Date"/>
    <alias field="relative_to_terrain" index="9" name="Relative to Terrain"/>
    <alias field="relative_to_water" index="10" name="Relative to Water"/>
    <alias field="last_modification_date" index="11" name="Last Modification Date"/>
    <alias field="updating_person" index="12" name="Updating Person"/>
    <alias field="reason_for_update" index="13" name="Reason for Update"/>
    <alias field="lineage" index="14" name="Lineage"/>
    <alias field="area" index="15" name="Area"/>
    <alias field="area_uom" index="16" name="Area UoM"/>
    <alias field="construction_id" index="19" name="Construction ID"/>
    <alias field="surfacegeometry_id" index="22" name="Surface Geometry ID"/>
    <alias field="thermalboundary_contains_ID" index="23" name="Thermalboundary Contains ID"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint unique_strength="1" notnull_strength="0" exp_strength="0" constraints="4" field="ng_co_id"/>
    <constraint unique_strength="1" notnull_strength="1" exp_strength="0" constraints="3" field="id"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="1" constraints="4" field="area"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="1" constraints="4" field="area_uom"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="(&quot;area&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;area_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;area&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;area_uom&quot; IS NULL)" desc="Both values must either be NULL or NOT NULL" field="area"/>
    <constraint exp="(&quot;area&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;area_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;area&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;area_uom&quot; IS NULL)" desc="Both values must either be NULL or NOT NULL" field="area_uom"/>
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
    <attributeEditorContainer name="Main Info" visibilityExpressionEnabled="0" showLabel="0" height="250" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="id" showLabel="1" index="0"/>
      <attributeEditorField name="description" showLabel="1" index="1"/>
      <attributeEditorField name="gmlid" showLabel="1" index="2"/>   
      <attributeEditorField name="gmlid_codespace" showLabel="1" index="3"/>
      <attributeEditorField name="name" showLabel="1" index="4"/>
      <attributeEditorField name="name_codespace" showLabel="1" index="5"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Database Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="creation_date" showLabel="1" index="6"/>
        <attributeEditorField name="termination_date" showLabel="1" index="7"/>
        <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
        <attributeEditorField name="updating_person" showLabel="1" index="11"/>
        <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
        <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Relation to surface" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorField name="relative_to_terrain" showLabel="1" index="8"/>
      <attributeEditorField name="relative_to_water" showLabel="1" index="9"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Ext ref (Name)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_xx" label="Form Ext ref (Name)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Ext ref (Uri)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Ext ref (Uri)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <attributeEditorContainer name="Gen Attrib (String)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (String)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Integer)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Integer)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Real)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Real)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Measure)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Measure)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Date)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Date)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Uri)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Uri)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <attributeEditorContainer name="Feature-specific attributes" visibilityExpressionEnabled="0" showLabel="0" visibilityExpression="0" columnCount="2">
      <attributeEditorField name="area" showLabel="1" index=""/>
      <attributeEditorField name="area_uom" showLabel="1" index=""/>
      <attributeEditorField name="construction_id" showLabel="1" index=""/>
      <attributeEditorField name="surfacegeometry_id" showLabel="1" index=""/>
      <attributeEditorField name="thermalzone_contains_id" showLabel="1" index=""/>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field editable="0" name="construction_id"/>
    <field editable="0" name="creation_date"/>
    <field editable="0" name="gmlid"/>
    <field editable="0" name="gmlid_codespace"/>
    <field editable="0" name="id"/>
    <field editable="0" name="last_modification_date"/>
    <field editable="0" name="lineage"/>
    <field editable="0" name="name"/>
    <field editable="0" name="name_codespace"/>
    <field editable="0" name="ng_co_id"/>
    <field editable="0" name="updating_person"/>
    <field editable="0" name="termination_date"/>
    <field editable="0" name="thermalboundary_contains_id"/>
    <field editable="0" name="surfacegeometry_id"/>
  </editable>
  <labelOnTop></labelOnTop>
  <reuseLastValue></reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
</qgis>
